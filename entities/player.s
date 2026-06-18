.data

msg1: 	.string "aqui!\n"


.text
.globl SETUP_PLAYER
.globl UPDATE_PLAYER
.globl RENDER_PLAYER

SETUP_PLAYER:

    la t0, PLAYER_STATE
    sw   zero, 0(t0)
    ret

UPDATE_PLAYER:
    addi sp, sp, -4
    sw   ra, 0(sp)

    call PLAYER_HANDLE_INPUT

    lw   ra, 0(sp)
    addi sp, sp, 4
    ret

RENDER_PLAYER:
    ret

PLAYER_HANDLE_INPUT:

    la   t0, INPUT_CURRENT
    lw   t1, 0(t0)

    andi t2, t1, 0x03    # INPUT_LEFT | INPUT_RIGHT
    
    la  t0, INPUT_PRESSED
    lw  t4, 0(t0)

    andi t5, t4, INPUT_JUMP
    bnez t5, PLAYER_JUMP

CONTINUE_HANDLE_INPUT:

    li   t3, INPUT_LEFT
    beq  t2, t3, PLAYER_MOVE_LEFT

    li   t3, INPUT_RIGHT
    beq  t2, t3, PLAYER_MOVE_RIGHT

    ret

PLAYER_JUMP:
    li a7, 11
    li a0, 'J'
    ecall

    li a7, 11
    li a0, 10      # '\n'
    ecall

    j CONTINUE_HANDLE_INPUT


PLAYER_MOVE_RIGHT:

    li a7, 11
    li a0, 'R'
    ecall



    li a7, 11
    li a0, 10      # '\n'
    ecall


    ret

PLAYER_MOVE_LEFT:
    li a7, 11
    li a0, 'L'
    ecall

    li a7, 11
    li a0, 10      # '\n'
    ecall

    ret
