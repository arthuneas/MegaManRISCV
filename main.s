# ===========================================================================
# main.asm - Ponto de Entrada do Jogo Base
# ===========================================================================
.data

.include "consts.s"
.include "imagens/MAPA1_defs.s"
.include "imagens/MAPA1_colisao.s"
.include "imagens/MAPA1_entidades.s"
.include "imagens/MAPA1_tileset_offsets.s"
.include "imagens/MAPA1_visual.s"
.include "imagens/tileset.data"


.eqv STATE_PLAYING   2

BG_POS:     .half 0, 0
OLD_BG_POS: .half 0, 0

.text
.globl main
main:
        li s0, 0                # Framebuffer atual = 0
        li s1, STATE_PLAYING    # Estado = gameplay

        call SETUP_PLAYER

GAME_LOOP:
        call READ_INPUT
        call UPDATE_GAME
        call RENDER_FRAME

        
        # Manda o framebuffer atual para o display
        li   t0, 0xFF200604
        sw   s0, 0(t0)

        # Alterna framebuffer
        xori s0, s0, 1

        # Controle de framerate (~60 FPS = ~16ms por frame)
        li a7, 32               # Syscall: sleep
        li a0, 16
        ecall

        j GAME_LOOP

UPDATE_GAME:
        addi sp, sp, -4
        sw   ra, 0(sp)

        call UPDATE_PLAYER

        lw   ra, 0(sp)
        addi sp, sp, 4
        ret

RENDER_FRAME:
        addi sp, sp, -4
        sw ra, 0(sp)


        # Calcula endereço do framebuffer
        li   t0, 0xFF0
        add  t0, t0, s0
        slli t0, t0, 20 # t0 = 0xFF000000 ou 0xFF100000 dependendo do framebuffer atual


        la a0, MAPA1_VISUAL
        li a1, MAPA1_MAP_COLS
        li a2, MAPA1_MAP_ROWS
        mv a3,t0
        call RENDER_MAPA

        # Fundo azul escuro
        # li a0, 0x001122
        # mv a1, s0
        # call CLEAR_SCREEN

        # Jogador
        # call RENDER_PLAYER

        lw ra, 0(sp)
        addi sp, sp, 4
        ret

# ===========================================================================
# Includes
# ===========================================================================
.include "engine/render.s"
.include "engine/input.s"

.include "entities/player.s"
# .include "engine/physics.asm"
# .include "entities/player.asm"
