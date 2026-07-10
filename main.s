# ===========================================================================
# main.s - Ponto de entrada do jogo
# ===========================================================================
.data

.include "consts.s"
.include "assets/tileset/tileset.data"
.include "assets/maps/MAPA_defs.s"
.include "assets/maps/MAPA_tileset_offsets.s"
.include "assets/maps/MAPA1_entidades.s"
.include "assets/maps/MAPA1_colisao.s"
.include "assets/maps/MAPA1_visual.s"
.include "assets/maps/MAPA2_entidades.s"
.include "assets/maps/MAPA2_colisao.s"
.include "assets/maps/MAPA2_visual.s"
.include "assets/sprites/player/megaman_frames.data"
.include "assets/sprites/player/shoot.data"
.include "assets/sprites/enemies/enemy1_frames.data"
.include "assets/sprites/misc/dead_frames.data"
.include "assets/sprites/hud/lifeBar.data"

BG_POS:     .half 0, 0
OLD_BG_POS: .half 0, 0

.eqv MAP_DESC_VISUAL_OFF, 0
.eqv MAP_DESC_COLISAO_OFF, 4
.eqv MAP_DESC_PLAYER_OFF, 8
.eqv MAP_DESC_INIMIGO1_OFF, 12
.eqv MAP_DESC_INIMIGO1_COUNT_OFF, 16
.eqv MAP_DESC_SIZE, 20

MAPA1_DESCRIPTOR:
        .word MAPA1_VISUAL
        .word MAPA1_COLISAO
        .word MAPA1_PLAYER
        .word MAPA1_INIMIGO1
        .word MAPA1_INIMIGO1_COUNT

MAPA2_DESCRIPTOR:
        .word MAPA2_VISUAL
        .word MAPA2_COLISAO
        .word MAPA2_PLAYER
        .word MAPA2_INIMIGO1
        .word MAPA2_INIMIGO1_COUNT

CURRENT_MAP_VISUAL:         .word MAPA1_VISUAL
CURRENT_MAP_COLISAO:        .word MAPA1_COLISAO
CURRENT_MAP_PLAYER:         .word MAPA1_PLAYER
CURRENT_MAP_INIMIGO1:       .word MAPA1_INIMIGO1
CURRENT_MAP_INIMIGO1_COUNT: .word MAPA1_INIMIGO1_COUNT

.text

main:
        li s0, 0
        la a0, MAPA1_DESCRIPTOR
        call MAP_SET_CURRENT
        call PLAYER_SETUP
        call ENEMY1_SETUP

GAME_LOOP:

        call READ_INPUT
        call UPDATE_GAME
        call RENDER_FRAME
        call PRESENT_FRAME
        call SWAP_FRAMEBUFFER
        call WAIT_FRAME

        j GAME_LOOP

# MAP_SET_CURRENT
# a0 = endereco do descriptor do mapa
MAP_SET_CURRENT:
        la t0, CURRENT_MAP_VISUAL
        li t1, MAP_DESC_SIZE
_MAP_SET_CURRENT_LOOP:
        beqz t1, _MAP_SET_CURRENT_DONE
        lw t2, 0(a0)
        sw t2, 0(t0)
        addi a0, a0, 4
        addi t0, t0, 4
        addi t1, t1, -4
        j _MAP_SET_CURRENT_LOOP
_MAP_SET_CURRENT_DONE:
        ret

UPDATE_GAME:
        addi sp, sp, -4
        sw   ra, 0(sp)

        call PLAYER_UPDATE
        call ENEMY1_UPDATE
        call CAMERA_UPDATE
        # call MUSIC_UPDATE

        lw   ra, 0(sp)
        addi sp, sp, 4
        ret

RENDER_FRAME:
        addi sp, sp, -8
        sw ra, 0(sp)
        sw s2, 4(sp)

        call GAME_GET_FRAMEBUFFER_ADDR
        mv s2, a0

        la t0, CURRENT_MAP_VISUAL
        lw a0, 0(t0)
        li a1, MAPA_MAP_COLS
        li a2, MAPA_MAP_ROWS
        mv a3, s2
        call RENDER_MAPA

        mv a3, s2
        call PLAYER_RENDER

        mv a3, s2
        call ENEMY1_RENDER

        mv a3, s2
        call HUD_RENDER

        lw s2, 4(sp)
        lw ra, 0(sp)
        addi sp, sp, 8
        ret

# GAME_GET_FRAMEBUFFER_ADDR
# retorna a0 = endereco base do framebuffer atual.
GAME_GET_FRAMEBUFFER_ADDR:
        li   a0, 0xFF0
        add  a0, a0, s0
        slli a0, a0, 20
        ret

PRESENT_FRAME:
        li t0, 0xFF200604
        sw s0, 0(t0)
        ret

SWAP_FRAMEBUFFER:
        xori s0, s0, 1
        ret

WAIT_FRAME:
        li a7, 32               # Syscall: sleep
        li a0, 30
        ecall
        ret

# ===========================================================================
# Includes
# ===========================================================================
.include "engine/render.s"
.include "engine/input.s"
.include "engine/physics.s"
.include "engine/camera.s"
.include "engine/animation.s"
.include "engine/music.s"
.include "utils.s"
.include "hud.s"

.include "entities/player.s"
.include "entities/enemy1.s"
