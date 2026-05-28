# ===========================================================================
# engine/render.asm - Motor de Renderização Base
# ===========================================================================

.text

# PRINT: Copia uma matriz de pixels para o Framebuffer (sem transparência)
# a0 = endereço do sprite
# a1 = posição X em pixels
# a2 = posição Y em pixels
# a3 = framebuffer (0 ou 1)
.globl PRINT
PRINT:
        # t0 = Base do Framebuffer
        li t0,0xFF0
        add t0,t0,a3
        slli t0,t0,20

        # Offset Y
        li t1,1280         # 320 pixels * 4 bytes
        mul t1,t1,a2
        add t0,t0,t1
        
        # Offset X
        slli a1,a1,2       # Converte pixel_x para bytes
        add t0,t0,a1

        # t1 = Endereço inicial dos pixels da imagem
        addi t1,a0,8

        lw t4,0(a0)         # Largura (bytes)
        lw t5,4(a0)         # Altura (linhas)

        mv t2,zero          # Contador linha
PRINT_LINHA:
        mv t3,zero          # Contador coluna
PRINT_PIXEL:
        lw t6,0(t1)         # Lê pixel
        sw t6,0(t0)         # Escreve
        addi t0,t0,4
        addi t1,t1,4
        addi t3,t3,4
        blt t3,t4,PRINT_PIXEL

        # Pula para a próxima linha do framebuffer
        addi t0,t0,1280
        sub t0,t0,t4

        addi t2,t2,1
        blt t2,t5,PRINT_LINHA
        ret

# CLEAR_SCREEN: Pinta a tela toda de uma cor
# a0 = cor
# a1 = framebuffer
.globl CLEAR_SCREEN
CLEAR_SCREEN:
        li t0,0xFF0
        add t0,t0,a1
        slli t0,t0,20
        li t1,307200
        add t1,t1,t0
CLEAR_LOOP:
        sw a0,0(t0)
        addi t0,t0,4
        blt t0,t1,CLEAR_LOOP
        ret
