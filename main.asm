# ===========================================================================
# main.asm - Ponto de Entrada do Jogo Base
# ===========================================================================
# Boilerplate extremamente enxuto e seguro para testes.
# ===========================================================================

.eqv STATE_PLAYING   2

.text
.globl main
main:
        li s0, 0                # Framebuffer atual = 0
        li s1, STATE_PLAYING    # Estado = gameplay

        call SETUP_PLAYER

GAME_LOOP:
        call READ_INPUT
        call UPDATE_PLAYER
        call RENDER_FRAME

        # Alterna framebuffer (double buffering)
        xori s0, s0, 1

        # Controle de framerate (~60 FPS = ~16ms por frame)
        li a7, 32               # Syscall: sleep
        li a0, 16
        ecall

        j GAME_LOOP

RENDER_FRAME:
        addi sp, sp, -4
        sw ra, 0(sp)

        # Fundo azul escuro
        li a0, 0x001122
        mv a1, s0
        call CLEAR_SCREEN

        # Jogador
        call RENDER_PLAYER

        lw ra, 0(sp)
        addi sp, sp, 4
        ret

# ===========================================================================
# Includes
# ===========================================================================
.include "engine/render.asm"
.include "engine/input.asm"
.include "engine/physics.asm"
.include "entities/player.asm"
