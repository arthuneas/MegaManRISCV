# MegaManRISCV


[Sprites](https://www.spriters-resource.com/nes/mm2/) 

[Jogo](https://playclassic.games/games/platform-nes-games-online/mega-man-2/play/)

[Músicas](https://www.khinsider.com/midi/nes/mega-man-2)

[Repositório Lamar](https://github.com/victorlisboa/LAMAR)


**Requisitos:**
1) (0,5) Música e efeitos sonoros.
2) (0,5) Ataque base do jogador.
3) (1,0) Movimentação e animação do personagem jogável.
4) (1,5) Mínimo de 2 habilidades do Mega Man, permitindo que ele troque entre elas, impactando no
combate e/ou na movimentação.
5) (0,5) Informações sobre a vida e carga das habilidades do Mega Man.
6) (0,5) Itens coletáveis de cura e de recarga das habilidades.
7) (1,0) Pelo menos 2 áreas distintas, isto é, dois ambientes de estilos diferentes, separados por uma porta.
8) (1,5) Mínimo de 3 tipos de inimigos com IAs diferentes (número de inimigos em aberto), sendo um deles
um chefão.
9) (1,0) Background móvel que acompanhe o movimento do Mega Man (horizontal ou vertical)


[OAC_Projeto_2026_1.pdf](https://github.com/user-attachments/files/28319086/OAC_Projeto_2026_1.pdf)


# Organização do Projeto

```
MegaManRISCV/
├── engine/              ← Motor do jogo (animação, entrada, física, 
├── entities/            ← Entidades do jogo (Mega Man)
├── assets/              ← Recursos do jogo
│   ├── enemies/         ← Sprites de inimigos
│   ├── tiles/           ← Blocos do mapa
│   ├── items/           ← Itens coletáveis
│   ├── hud/             ← Interface do jogo
│   ├── backgrounds/     ← Fundos das fases
│   └── sprites/         ← Sprites em bruto
├── exemplos/            ← Exemplos de código
├── main.asm             ← Arquivo principal
├── macros.asm           ← Macros e utilitários
```

# Imagens / Sprites

Todos os arquivos `.data` convertidos de sprites ficam em `assets/`.

## Como converter sprites:

1. Recorte o sprite do sheet como PNG
2. **Largura DEVE ser múltiplo de 4** (ex: 16, 20, 24, 28, 32)
3. Use o conversor: https://github.com/ABMHub/png2oac
4. Coloque o `.data` na subpasta correta dentro de `assets/`

## Formato do .data gerado:

O conversor gera um arquivo com:
- Word 0: largura em pixels
- Word 1: altura em pixels  
- Restante: dados de cor, 1 word por pixel
