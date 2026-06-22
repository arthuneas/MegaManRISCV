# Plano de Implementação da Entity Player

Este documento descreve como implementar a entidade do jogador no `MegaManRISCV`
usando máquina de estados, integrando com o `main.s`, `engine/input.s`,
`engine/render.s` e o mapa modularizado.

O objetivo é substituir o exemplo antigo de `entities/player.asm` por um módulo
novo em `entities/player.s`, mantendo o `player.asm` apenas como referência.

---

## 1. Papel do módulo

O módulo `entities/player.s` deve ser responsável por:

- inicializar os dados do jogador;
- ler o estado de input já processado por `READ_INPUT`;
- atualizar a máquina de estados;
- aplicar movimento horizontal;
- aplicar pulo, queda e gravidade;
- resolver colisão com o mapa;
- escolher direção e animação;
- renderizar o jogador no framebuffer recebido pelo frame atual.

Ele não deve:

- ler diretamente o keymap do FPGRARS;
- trocar framebuffer;
- renderizar o mapa;
- controlar o loop principal do jogo;
- depender de `main.asm`.

---

## 2. Arquivos envolvidos

### Arquivo principal

```text
entities/player.s
```

Este deve ser o novo módulo real do player.

### Arquivos de suporte

```text
consts.s
engine/input.s
engine/render.s
main.s
imagens/MAPA1_colisao.s
imagens/MAPA1_defs.s
```

### Arquivo antigo

```text
entities/player.asm
```

Tem valor apenas como exemplo de organização. Ele não deve ser usado como base
direta porque move o jogador livremente em 4 direções, sem física de plataforma,
gravidade, colisão real, estados ou sprites definitivos.

---

## 3. Interface pública do player

O módulo deve expor três rotinas principais:

```asm
.globl SETUP_PLAYER
.globl UPDATE_PLAYER
.globl RENDER_PLAYER
```

### `SETUP_PLAYER`

Inicializa posição, velocidade, direção, estado e animação.

Uso esperado:

```asm
call SETUP_PLAYER
```

Deve ser chamada uma vez antes do `GAME_LOOP`.

### `UPDATE_PLAYER`

Atualiza lógica do jogador para um frame.

Uso esperado:

```asm
call READ_INPUT
call UPDATE_PLAYER
```

Deve ler:

- `INPUT_CURRENT` para ações contínuas;
- `INPUT_PRESSED` para eventos de um frame;
- `INPUT_RELEASED` somente quando soltar botão importar.

### `RENDER_PLAYER`

Desenha o jogador no framebuffer atual.

Sugestão de assinatura:

```asm
# a0 = endereco base do framebuffer
call RENDER_PLAYER
```

Isso mantém o mesmo padrão novo do render: o `main.s` calcula o endereço do
framebuffer uma vez por frame e passa para quem desenha.

---

## 4. Integração com `main.s`

Fluxo recomendado:

```asm
main:
        li s0, 0                # id do framebuffer atual
        li s1, STATE_PLAYING

        call SETUP_PLAYER

GAME_LOOP:
        call READ_INPUT
        call UPDATE_PLAYER
        call RENDER_FRAME

        li   t0, 0xFF200604
        sw   s0, 0(t0)

        xori s0, s0, 1

        li a7, 32
        li a0, 16
        ecall

        j GAME_LOOP
```

Dentro de `RENDER_FRAME`:

```asm
# t0 = endereco base do framebuffer calculado no inicio do frame

la a0, MAPA1_VISUAL
li a1, MAPA1_MAP_COLS
li a2, MAPA1_MAP_ROWS
mv a3, t0
call RENDER_MAPA

mv a0, t0
call RENDER_PLAYER
```

O `RENDER_PLAYER` recebe o endereço base do framebuffer, não o id `0/1`.

---

## 5. Dados do jogador

Recomenda-se concentrar os dados do player em `entities/player.s`.

Exemplo de dados necessários:

```asm
.data
.globl PLAYER_POS
.globl PLAYER_OLD_POS
.globl PLAYER_VEL_X
.globl PLAYER_VEL_Y
.globl PLAYER_DIR
.globl PLAYER_STATE
.globl PLAYER_FRAME
.globl PLAYER_ANIM_TIMER

PLAYER_POS:        .half 16, 168
PLAYER_OLD_POS:    .half 16, 168
PLAYER_VEL_X:      .word 0
PLAYER_VEL_Y:      .word 0
PLAYER_DIR:        .word 1      # 1 = direita, -1 = esquerda
PLAYER_STATE:      .word STATE_IDLE
PLAYER_FRAME:      .word 0
PLAYER_ANIM_TIMER: .word 0
```

Observação: hoje `PLAYER_STATE` está em `consts.s`. No longo prazo, faz mais
sentido deixar constantes em `consts.s` e dados mutáveis do jogador em
`entities/player.s`. Se mover esse símbolo, deve haver apenas uma definição.

---

## 6. Constantes recomendadas

As constantes de estado já existem em `consts.s`:

```asm
.eqv STATE_IDLE          0
.eqv STATE_ANDANDO       1
.eqv STATE_NO_AR         2
.eqv STATE_ATIRANDO      3
.eqv STATE_ATIRA_PULANDO 4
.eqv STATE_NA_ESCADA     5
.eqv STATE_ATIRA_ESCADA  6
.eqv STATE_KNOCKBACK     7
```

Estados suficientes para a primeira versão:

```text
STATE_IDLE
STATE_ANDANDO
STATE_NO_AR
STATE_NA_ESCADA
STATE_KNOCKBACK
```

Estados de tiro podem entrar depois:

```text
STATE_ATIRANDO
STATE_ATIRA_PULANDO
STATE_ATIRA_ESCADA
```

Constantes físicas sugeridas:

```asm
.eqv PLAYER_SPEED_X       2
.eqv PLAYER_JUMP_SPEED   -8
.eqv PLAYER_GRAVITY       1
.eqv PLAYER_MAX_FALL      6
.eqv PLAYER_DIR_RIGHT     1
.eqv PLAYER_DIR_LEFT     -1
```

---

## 7. Ordem de atualização por frame

`UPDATE_PLAYER` deve ser uma rotina orquestradora:

```asm
UPDATE_PLAYER:
        call PLAYER_SAVE_OLD_POS
        call PLAYER_READ_COMMANDS
        call PLAYER_UPDATE_STATE
        call PLAYER_APPLY_HORIZONTAL
        call PLAYER_APPLY_VERTICAL
        call PLAYER_RESOLVE_COLLISIONS
        call PLAYER_UPDATE_ANIMATION
        ret
```

Essa separação evita que a FSM, a física e a colisão fiquem misturadas.

---

## 8. Input: como usar

O `engine/input.s` já entrega três valores:

```text
INPUT_CURRENT  -> teclas seguradas neste frame
INPUT_PRESSED  -> teclas que ligaram neste frame
INPUT_RELEASED -> teclas que desligaram neste frame
```

Uso recomendado:

```text
Movimento horizontal: INPUT_CURRENT
Pulo:                 INPUT_PRESSED
Tiro:                 INPUT_PRESSED
Escada:               INPUT_CURRENT
Trocar arma:          INPUT_PRESSED
```

Exemplo de regra:

```text
Se INPUT_CURRENT tem INPUT_RIGHT:
    PLAYER_DIR = direita
    PLAYER_VEL_X = +PLAYER_SPEED_X

Se INPUT_CURRENT tem INPUT_LEFT:
    PLAYER_DIR = esquerda
    PLAYER_VEL_X = -PLAYER_SPEED_X

Se nenhum dos dois:
    PLAYER_VEL_X = 0
```

Para pulo:

```text
Se INPUT_PRESSED tem INPUT_JUMP e estado permite pular:
    PLAYER_VEL_Y = PLAYER_JUMP_SPEED
    PLAYER_STATE = STATE_NO_AR
```

---

## 9. Máquina de estados

### Estado `STATE_IDLE`

Condição:

- jogador no chão;
- sem movimento horizontal.

Transições:

```text
RIGHT/LEFT segurado  -> STATE_ANDANDO
JUMP pressionado     -> STATE_NO_AR
DOWN/UP em escada    -> STATE_NA_ESCADA
Tomou dano           -> STATE_KNOCKBACK
```

### Estado `STATE_ANDANDO`

Condição:

- jogador no chão;
- movendo horizontalmente.

Transições:

```text
soltou LEFT/RIGHT    -> STATE_IDLE
JUMP pressionado     -> STATE_NO_AR
saiu do chão         -> STATE_NO_AR
DOWN/UP em escada    -> STATE_NA_ESCADA
Tomou dano           -> STATE_KNOCKBACK
```

### Estado `STATE_NO_AR`

Condição:

- jogador pulando ou caindo.

Transições:

```text
encostou no chão     -> STATE_IDLE ou STATE_ANDANDO
encostou em escada   -> STATE_NA_ESCADA, se input permitir
Tomou dano           -> STATE_KNOCKBACK
```

Observação: para a primeira versão, não precisa separar pulando e caindo em
estados diferentes. A direção de `PLAYER_VEL_Y` já informa isso.

### Estado `STATE_NA_ESCADA`

Condição:

- jogador alinhado ou sobreposto a uma tile de escada.

Transições:

```text
JUMP pressionado     -> STATE_NO_AR
saiu da escada       -> STATE_NO_AR ou STATE_IDLE
chegou no chão       -> STATE_IDLE
Tomou dano           -> STATE_KNOCKBACK
```

Durante escada:

- gravidade deve ser desligada ou ignorada;
- `INPUT_UP` move para cima;
- `INPUT_DOWN` move para baixo;
- `INPUT_LEFT/RIGHT` pode mudar direção, mas não deve necessariamente mover fora da escada.

### Estado `STATE_KNOCKBACK`

Condição:

- jogador tomou dano e está temporariamente sem controle.

Transições:

```text
timer terminou e está no chão -> STATE_IDLE
timer terminou e está no ar   -> STATE_NO_AR
```

Durante knockback:

- input de movimento deve ser ignorado;
- física vertical ainda deve rodar;
- invulnerabilidade pode continuar após o knockback acabar.

---

## 10. Regras de prioridade

Quando mais de uma coisa acontece no mesmo frame, use prioridade fixa:

```text
1. dano / knockback
2. escada
3. pulo
4. movimento horizontal
5. idle
```

Isso evita conflito como:

- apertar pulo e escada no mesmo frame;
- tomar dano enquanto atira;
- andar e ficar parado no mesmo frame;
- cair e entrar em idle antes da colisão confirmar chão.

---

## 11. Física

### Movimento horizontal

Fluxo recomendado:

```text
1. calcula PLAYER_VEL_X pelo input;
2. soma PLAYER_VEL_X em PLAYER_POS.x;
3. testa colisão horizontal;
4. se colidiu, desfaz ou ajusta posição.
```

### Movimento vertical

Fluxo recomendado:

```text
1. se não estiver em escada, aplica gravidade;
2. limita PLAYER_VEL_Y em PLAYER_MAX_FALL;
3. soma PLAYER_VEL_Y em PLAYER_POS.y;
4. testa colisão vertical;
5. se caiu no chão, zera PLAYER_VEL_Y e atualiza estado;
6. se bateu a cabeça, zera PLAYER_VEL_Y e começa queda.
```

### Pulo

O pulo deve usar `INPUT_PRESSED`, não `INPUT_CURRENT`.

Regra:

```text
Só inicia pulo se o estado atual permitir:
    STATE_IDLE
    STATE_ANDANDO
    STATE_NA_ESCADA
```

---

## 12. Colisão com mapa

O player deve consultar o mapa de colisão, não o mapa visual.

Dados necessários:

```text
MAPA1_COLISAO
MAPA1_MAP_COLS
MAPA1_MAP_ROWS
BG_POS
TILE_W
TILE_H
```

Pontos principais do retângulo do player:

```text
left   = player_x + bg_x
right  = player_x + bg_x + PLAYER_LARGURA - 1
top    = player_y + bg_y
bottom = player_y + bg_y + PLAYER_ALTURA - 1
```

Conversão para tile:

```text
tile_x = world_x >> TILE_W_SHIFT
tile_y = world_y >> TILE_H_SHIFT
index  = tile_y * MAPA1_MAP_COLS + tile_x
```

Primeira versão recomendada:

- checar tiles nos cantos do retângulo;
- tratar tile sólido;
- depois adicionar escada;
- depois adicionar dano, spikes ou entidades.

---

## 13. Scroll e posição

O render do mapa usa `BG_POS`. O player deve trabalhar com dois conceitos:

```text
screen_x -> posição na tela
world_x  -> screen_x + BG_POS.x
```

Para uma primeira implementação, manter `PLAYER_POS.x` como posição de tela é
mais simples, porque o render já desenha em coordenadas de tela.

Quando o jogador chega perto da borda direita:

```text
se PLAYER_POS.x > limite_camera e BG_POS.x < BG_X_MAX:
    aumenta BG_POS.x
    mantém PLAYER_POS.x perto do limite_camera
```

Quando o jogador volta para a esquerda:

```text
se PLAYER_POS.x < limite_camera_esquerdo e BG_POS.x > BG_X_MIN:
    diminui BG_POS.x
    mantém PLAYER_POS.x perto do limite_camera_esquerdo
```

Essa regra pode ficar dentro de uma rotina futura:

```asm
PLAYER_UPDATE_CAMERA:
```

---

## 14. Render do player

`RENDER_PLAYER` deve receber o framebuffer base:

```asm
# a0 = framebuffer base
```

Internamente:

```text
1. escolhe sprite com base em PLAYER_STATE, PLAYER_DIR e PLAYER_FRAME;
2. carrega PLAYER_POS.x em a1;
3. carrega PLAYER_POS.y em a2;
4. passa framebuffer base para a rotina de desenho;
5. desenha sprite.
```

Se ainda não houver rotina definitiva para sprites, usar uma rotina temporária
é aceitável, desde que a interface final já seja:

```text
sprite + x + y + framebuffer_base
```

Evite voltar ao padrão antigo de passar apenas o id `0/1` do framebuffer.

---

## 15. Animação

O estado escolhe a família de animação:

```text
STATE_IDLE       -> idle
STATE_ANDANDO    -> andando
STATE_NO_AR      -> pulo/queda
STATE_NA_ESCADA  -> escada
STATE_KNOCKBACK  -> dano
```

`PLAYER_FRAME` escolhe o quadro dentro da animação.

`PLAYER_ANIM_TIMER` controla a velocidade:

```text
timer += 1
se timer >= delay_da_animacao:
    timer = 0
    frame += 1
```

Na primeira versão, pode usar um sprite fixo por estado. Depois evolui para
tabelas de frames.

---

## 16. Convenções de registradores

Rotinas públicas que chamam outras rotinas devem salvar `ra`.

Exemplo:

```asm
UPDATE_PLAYER:
        addi sp, sp, -4
        sw   ra, 0(sp)

        call PLAYER_SAVE_OLD_POS
        call PLAYER_READ_COMMANDS

        lw   ra, 0(sp)
        addi sp, sp, 4
        ret
```

Use `t0-t6` livremente dentro de rotinas curtas.

Se uma rotina usar `s0-s11`, ela deve salvar e restaurar esses registradores.
Como `main.s` já usa `s0` para o id do framebuffer, o player não deve assumir
que pode usar `s0` como variável permanente interna.

---

## 17. Ordem de implementação

### Etapa 1: estrutura mínima

- criar `entities/player.s` com dados do player;
- implementar `SETUP_PLAYER`;
- implementar `UPDATE_PLAYER` vazio ou quase vazio;
- implementar `RENDER_PLAYER` temporário;
- incluir `entities/player.s` no `main.s`;
- ativar `call SETUP_PLAYER`, `call UPDATE_PLAYER` e `call RENDER_PLAYER`.

Critério de pronto:

- o jogo monta;
- o mapa continua renderizando;
- o player aparece em uma posição fixa.

### Etapa 2: movimento horizontal

- ler `INPUT_CURRENT`;
- aplicar esquerda/direita;
- atualizar `PLAYER_DIR`;
- limitar posição em tela;
- atualizar `STATE_IDLE` e `STATE_ANDANDO`.

Critério de pronto:

- segura `A` e move para esquerda;
- segura `D` e move para direita;
- solta as teclas e volta para idle;
- combinações de tecla não travam o player.

### Etapa 3: pulo e gravidade

- ler `INPUT_PRESSED` para `INPUT_JUMP`;
- aplicar `PLAYER_JUMP_SPEED`;
- aplicar gravidade;
- limitar queda;
- atualizar `STATE_NO_AR`.

Critério de pronto:

- pulo dispara uma vez por pressionamento;
- segurar pulo não reinicia o pulo todo frame;
- player cai depois de subir.

### Etapa 4: colisão vertical simples

- testar chão com mapa de colisão;
- ajustar posição ao pousar;
- zerar `PLAYER_VEL_Y`;
- voltar para `STATE_IDLE` ou `STATE_ANDANDO`.

Critério de pronto:

- player pousa em tile sólido;
- não atravessa o chão;
- estado volta corretamente ao tocar o chão.

### Etapa 5: colisão horizontal

- testar parede à esquerda e direita;
- impedir entrada em tile sólido;
- manter scroll e posição coerentes.

Critério de pronto:

- player não atravessa paredes;
- colisão horizontal não quebra o pulo.

### Etapa 6: câmera e scroll

- mover `BG_POS.x` quando o player cruza limite de câmera;
- manter `PLAYER_POS.x` em posição confortável na tela;
- respeitar `BG_X_MIN` e `BG_X_MAX`.

Critério de pronto:

- mapa rola;
- player não sai da tela;
- colisão continua usando coordenada de mundo.

### Etapa 7: escadas

- detectar tile de escada;
- entrar em `STATE_NA_ESCADA`;
- desligar gravidade na escada;
- permitir subir/descer com `INPUT_UP` e `INPUT_DOWN`;
- sair da escada por pulo, topo, base ou movimento.

Critério de pronto:

- player sobe e desce escada;
- não cai enquanto está na escada;
- volta ao estado correto ao sair.

### Etapa 8: tiro

- usar `INPUT_PRESSED` com `INPUT_SHOOT`;
- spawnar projétil em módulo separado;
- preservar estado de movimento quando possível.

Critério de pronto:

- atirar parado não quebra movimento;
- atirar andando não para o player;
- atirar no ar usa animação correta.

### Etapa 9: knockback e invulnerabilidade

- implementar timer de knockback;
- ignorar input durante knockback;
- aplicar empurrão horizontal;
- manter gravidade;
- implementar timer de invulnerabilidade.

Critério de pronto:

- dano empurra o player;
- controle volta ao terminar o timer;
- invulnerabilidade impede dano repetido imediato.

---

## 18. Primeiro alvo técnico

O primeiro objetivo concreto deve ser:

```text
Player parado aparece na tela, recebe framebuffer base em RENDER_PLAYER,
anda para esquerda/direita com INPUT_CURRENT e alterna entre
STATE_IDLE e STATE_ANDANDO.
```

Depois disso, adicionar pulo e gravidade.

Essa ordem reduz risco porque valida primeiro:

- include do módulo;
- dados do player;
- chamada pelo `main.s`;
- integração com input;
- integração com framebuffer;
- render em cima do mapa.

