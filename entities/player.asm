# ===========================================================================
# entities/player.asm - Entidade do Jogador (Exemplo Limpo)
# ===========================================================================
.eqv PLAYER_WIDTH    16
.eqv PLAYER_WIDTH_NEG -16
.eqv PLAYER_HEIGHT   24
.eqv PLAYER_HEIGHT_NEG -24
.eqv PLAYER_SPEED    2
.eqv PLAYER_SPEED_NEG -2

.data
.globl PLAYER_X
.globl PLAYER_Y
PLAYER_X:           .half 150       # X
PLAYER_Y:           .half 200       # Y

# Espaço de memória para desenhar um retângulo
.align 2
PLAYER_SPRITE_IDLE:
.space 1544         # 8 (metadata) + 16*24*4 (pixels)

.text

.globl SETUP_PLAYER
SETUP_PLAYER:
        la t0, PLAYER_X
        li t1, 150
        sh t1, 0(t0)
        li t1, 200
        sh t1, 2(t0)

        # Gera o sprite quadrado azul claro para debug/exemplo
        la t0, PLAYER_SPRITE_IDLE
        li t1, 64               # 16 pixels * 4 bytes
        sw t1, 0(t0)
        li t1, 24               # Altura
        sw t1, 4(t0)
        
        addi t0, t0, 8
        li t1, 384              # 16 * 24 = total pixels
        li t2, 0
        li t3, 0x00AAFF         # Cor base (azul claro)
FILL_SPRITE:
        sw t3, 0(t0)
        addi t0, t0, 4
        addi t2, t2, 1
        blt t2, t1, FILL_SPRITE
        ret


.globl UPDATE_PLAYER
UPDATE_PLAYER:
        addi sp, sp, -8
        sw ra, 0(sp)
        sw s2, 4(sp)

        la t0, INPUT_FLAGS
        lw t0, 0(t0)           # Teclas

        la s2, PLAYER_X
        lh t1, 0(s2)           # X
        lh t2, 2(s2)           # Y

        andi t3, t0, INPUT_LEFT
        beqz t3, CHECK_RIGHT
        addi t1, t1, PLAYER_SPEED_NEG
CHECK_RIGHT:
        andi t3, t0, INPUT_RIGHT
        beqz t3, CHECK_UP
        addi t1, t1, PLAYER_SPEED
CHECK_UP:
        andi t3, t0, INPUT_UP
        beqz t3, CHECK_DOWN
        addi t2, t2, PLAYER_SPEED_NEG
CHECK_DOWN:
        andi t3, t0, INPUT_DOWN
        beqz t3, CLAMP_POS
        addi t2, t2, PLAYER_SPEED

CLAMP_POS:
        bgez t1, CLAMP_X_MAX
        li t1, 0
CLAMP_X_MAX:
        li t3, 320
        addi t3, t3, PLAYER_WIDTH_NEG
        ble t1, t3, CLAMP_Y_MIN
        mv t1, t3
CLAMP_Y_MIN:
        bgez t2, CLAMP_Y_MAX
        li t2, 0
CLAMP_Y_MAX:
        li t3, 240
        addi t3, t3, PLAYER_HEIGHT_NEG
        ble t2, t3, STORE_POS
        mv t2, t3

STORE_POS:
        sh t1, 0(s2)
        sh t2, 2(s2)

        lw ra, 0(sp)
        lw s2, 4(sp)
        addi sp, sp, 8
        ret

.globl RENDER_PLAYER
RENDER_PLAYER:
        addi sp, sp, -4
        sw ra, 0(sp)

        la a0, PLAYER_SPRITE_IDLE
        la t0, PLAYER_X
        lh a1, 0(t0)                   # X (pixels)
        lh a2, 2(t0)                   # Y (pixels)
        mv a3, s0                       # Framebuffer
        call PRINT

        lw ra, 0(sp)
        addi sp, sp, 4
        ret
