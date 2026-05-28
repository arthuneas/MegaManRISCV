# Macros utilitárias para o projeto Mega Man RISC-V
# Inclua este arquivo no main.asm se quiser usar as macros

# ============================================================
# MACROS DE PILHA
# ============================================================

# Salva ra na pilha (use antes de chamar funções dentro de funções)
.macro PUSH_RA
    addi sp, sp, -4
    sw ra, 0(sp)
.end_macro

# Restaura ra da pilha
.macro POP_RA
    lw ra, 0(sp)
    addi sp, sp, 4
.end_macro

# Salva ra e s0-s3 na pilha (para funções mais complexas)
.macro PUSH_REGS
    addi sp, sp, -20
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
.end_macro

# Restaura ra e s0-s3 da pilha
.macro POP_REGS
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    addi sp, sp, 20
.end_macro
