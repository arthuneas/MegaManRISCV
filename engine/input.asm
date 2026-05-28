# ===========================================================================
# engine/input.asm - Sistema de Entrada do Teclado (Mega Man)
# ===========================================================================
# Lê teclas pressionadas via KDMMIO do FPGRARS e armazena como bit flags
# Controle KDMMIO: 0xFF200000 | Dados KDMMIO: 0xFF200004
# ===========================================================================

# ---------------------------------------------------------------------------
# Constantes de entrada - cada tecla é um bit único para permitir combinações
# ---------------------------------------------------------------------------
.eqv INPUT_LEFT   0x01    # Tecla 'a' - mover para esquerda
.eqv INPUT_RIGHT  0x02    # Tecla 'd' - mover para direita
.eqv INPUT_UP     0x04    # Tecla 'w' - olhar para cima / subir escada
.eqv INPUT_DOWN   0x08    # Tecla 's' - agachar / descer escada
.eqv INPUT_SHOOT  0x10    # Tecla 'j' - disparar
.eqv INPUT_JUMP   0x20    # Tecla 'k' - pular
.eqv INPUT_SWITCH 0x40    # Tecla 'l' - trocar arma

# ---------------------------------------------------------------------------
# Dados
# ---------------------------------------------------------------------------
.data
.globl INPUT_FLAGS
INPUT_FLAGS: .word 0       # Bit flags das teclas pressionadas neste frame

.text

# ===========================================================================
# READ_INPUT - Lê todas as teclas no buffer do KDMMIO
# ===========================================================================
# Argumentos: nenhum
# Retorno: INPUT_FLAGS é atualizado com os bit flags das teclas pressionadas
# Registradores usados: t0-t4
# Nota: função leaf, não precisa salvar ra na pilha
# ===========================================================================
.globl READ_INPUT
READ_INPUT:
        # Limpa as flags do frame anterior
        la t0,INPUT_FLAGS
        sw zero,0(t0)       # INPUT_FLAGS = 0

        li t1,0xFF200000    # Endereço de controle do KDMMIO
        mv t4,zero          # t4 = acumulador de flags

READ_INPUT_CHECK:
        # Verifica se há tecla disponível no buffer
        lw t2,0(t1)         # Lê registrador de controle
        andi t2,t2,0x0001  # Máscara para bit de tecla disponível
        beq t2,zero,READ_INPUT_DONE  # Se não há tecla, finaliza

        # Lê o valor da tecla pressionada
        lw t3,4(t1)         # Lê dado do KDMMIO (código da tecla)

        # --- Compara com cada tecla e ativa o bit correspondente ---

        li t2,'a'
        beq t3,t2,READ_INPUT_LEFT

        li t2,'d'
        beq t3,t2,READ_INPUT_RIGHT

        li t2,'w'
        beq t3,t2,READ_INPUT_UP

        li t2,'s'
        beq t3,t2,READ_INPUT_DOWN

        li t2,'j'
        beq t3,t2,READ_INPUT_SHOOT

        li t2,'k'
        beq t3,t2,READ_INPUT_JUMP

        li t2,'l'
        beq t3,t2,READ_INPUT_SWITCH

        # Tecla não reconhecida - volta a checar o buffer
        j READ_INPUT_CHECK

READ_INPUT_LEFT:
        ori t4,t4,INPUT_LEFT
        j READ_INPUT_CHECK     # Pode haver mais teclas no buffer

READ_INPUT_RIGHT:
        ori t4,t4,INPUT_RIGHT
        j READ_INPUT_CHECK

READ_INPUT_UP:
        ori t4,t4,INPUT_UP
        j READ_INPUT_CHECK

READ_INPUT_DOWN:
        ori t4,t4,INPUT_DOWN
        j READ_INPUT_CHECK

READ_INPUT_SHOOT:
        ori t4,t4,INPUT_SHOOT
        j READ_INPUT_CHECK

READ_INPUT_JUMP:
        ori t4,t4,INPUT_JUMP
        j READ_INPUT_CHECK

READ_INPUT_SWITCH:
        ori t4,t4,INPUT_SWITCH
        j READ_INPUT_CHECK

READ_INPUT_DONE:
        # Salva as flags acumuladas na memória
        la t0,INPUT_FLAGS
        sw t4,0(t0)
        ret
