# ===========================================================================
# fpga.s - Entrada para a DE1-SoC / RISCV-v24
# ===========================================================================
# MACROSv24 instala ExceptionHandling em utvec antes de cair no main do jogo.
# SYSTEMv24 implementa os ecalls usados por WAIT_FRAME e MUSIC_UPDATE.
# A RISCV-v24 inicializa sp no reset. Esta entrada deve ser montada pelo RARS
# para gerar os MIFs; para o FPGRARS, execute main.s diretamente.

.include "fpga/MACROSv24.s"

# Os registradores de proposito geral nao devem ser usados para detectar a
# plataforma contando apenas com o valor do reset. Marca explicitamente este
# build como FPGA antes de entrar no jogo. READ_INPUT e MUSIC_UPDATE usam
# gp=0 para selecionar os perifericos implementados pela RISCV-v24.
li gp, 0

.include "main.s"
.include "fpga/SYSTEMv24.s"
