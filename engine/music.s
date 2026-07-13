# ===========================================================================
# engine/music.s - Musica de fundo (nao bloqueante)
# ===========================================================================
# MUSIC_UPDATE deve ser chamada uma vez por frame. Ela nunca bloqueia o
# jogo: cada nota tem uma duracao (ms) e a funcao so dispara a proxima
# quando esse tempo (medido via syscall 30) tiver passado desde que a
# nota atual comecou. O estado (indice da nota atual + timestamp de
# inicio) fica guardado nas duas primeiras words de MUSIC_NOTAS.
# ===========================================================================

.data

# MUSIC_NOTAS
# word0 = numero de notas
# word1 = indice da nota atual (estado, mutavel)
# word2 = timestamp (ms) de quando a nota atual comecou (estado, mutavel)
# depois: um trio (altura, duracao_ms, 0) por nota
MUSIC_NOTAS:
    .word 76, 0, 0
    .word 78, 125, 0
    .word 77, 125, 0
    .word 76, 125, 0
    .word 76, 125, 0
    .word 74, 125, 0
    .word 73, 125, 0
    .word 72, 125, 0
    .word 73, 125, 0
    .word 71, 125, 0
    .word 70, 125, 0
    .word 69, 125, 0
    .word 67, 125, 0
    .word 66, 125, 0
    .word 65, 125, 0
    .word 77, 500, 0
    .word 77, 750, 0
    .word 77, 500, 0
    .word 77, 250, 0
    .word 76, 1250, 0
    .word 76, 250, 0
    .word 74, 500, 0
    .word 76, 500, 0
    .word 72, 500, 0
    .word 72, 250, 0
    .word 76, 500, 0
    .word 79, 500, 0
    .word 77, 1000, 0
    .word 77, 500, 0
    .word 76, 250, 0
    .word 79, 500, 0
    .word 77, 1000, 0
    .word 77, 250, 0
    .word 76, 250, 0
    .word 77, 1750, 0
    .word 77, 250, 0
    .word 79, 750, 0
    .word 77, 500, 0
    .word 76, 500, 0
    .word 74, 500, 0
    .word 74, 250, 0
    .word 76, 250, 0
    .word 74, 250, 0
    .word 72, 1000, 0
    .word 77, 500, 0
    .word 77, 750, 0
    .word 77, 500, 0
    .word 77, 250, 0
    .word 76, 1250, 0
    .word 76, 250, 0
    .word 74, 500, 0
    .word 76, 500, 0
    .word 72, 500, 0
    .word 72, 250, 0
    .word 76, 500, 0
    .word 79, 500, 0
    .word 77, 1000, 0
    .word 77, 500, 0
    .word 76, 250, 0
    .word 79, 500, 0
    .word 77, 1000, 0
    .word 77, 250, 0
    .word 76, 250, 0
    .word 77, 1750, 0
    .word 77, 250, 0
    .word 79, 750, 0
    .word 77, 500, 0
    .word 76, 500, 0
    .word 74, 500, 0
    .word 74, 250, 0
    .word 76, 250, 0
    .word 74, 250, 0
    .word 72, 1000, 0
    .word 77, 500, 0
    .word 77, 750, 0
    .word 77, 500, 0
    .word 77, 500, 0

.text

# MUSIC_UPDATE
# Sem argumentos, sem retorno. Chamar uma vez por frame.
MUSIC_UPDATE:
    addi sp, sp, -28
    sw   ra, 0(sp)
    sw   s1, 4(sp)
    sw   s2, 8(sp)
    sw   s3, 12(sp)
    sw   s4, 16(sp)
    sw   s5, 20(sp)
    sw   s6, 24(sp)

    la  s1, MUSIC_NOTAS
    lw  s2, 0(s1)           # total de notas
    lw  s3, 4(s1)           # indice da nota atual
    lw  s4, 8(s1)           # timestamp de inicio da nota atual

    li  t0, 12
    mul s5, t0, s3
    add s5, s5, s1           # s5 = &MUSIC_NOTAS[s3]

    li  a7, 30
    ecall                     # a0 = tempo atual (ms)
    sub s6, a0, s4            # tempo decorrido desde o inicio da nota

    lw  t1, 4(s5)             # duracao da nota atual
    bgtu t1, s6, _MUSIC_UPDATE_DONE   # ainda nao acabou, nada a fazer

    bne s3, s2, _MUSIC_UPDATE_NEXT
    li  s3, 0
    mv  s5, s1

_MUSIC_UPDATE_NEXT:
    addi s5, s5, 12

    li  a7, 31
    lw  a0, 0(s5)
    lw  a1, 4(s5)
    li  a2, 7                # instrumento (hardware aceita 0 a 15) - Clavinet, timbre tipo baixo
    li  a3, 60
    ecall                     # dispara a nota (nao bloqueia)

    li  a7, 30
    ecall
    sw  a0, 8(s1)             # salva novo timestamp de inicio

    addi s3, s3, 1
    sw  s3, 4(s1)             # salva novo indice

_MUSIC_UPDATE_DONE:
    lw   s6, 24(sp)
    lw   s5, 20(sp)
    lw   s4, 16(sp)
    lw   s3, 12(sp)
    lw   s2, 8(sp)
    lw   s1, 4(sp)
    lw   ra, 0(sp)
    addi sp, sp, 28
    ret
