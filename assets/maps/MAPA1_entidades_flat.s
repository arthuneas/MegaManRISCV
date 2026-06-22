# Gerado automaticamente pelo RITMO em 2026-06-22 12:44
# Mapa: 32 colunas x 30 linhas, tile 16x16 pixels
# Prefixo: MAPA1

.eqv MAPA1_FLAT_ENTITY_SIZE_BYTES 3
.eqv MAPA1_FLAT_NUM_ENTIDADES  3
.eqv MAPA1_FLAT_ENTITY_FIELD_TYPE 0
.eqv MAPA1_FLAT_ENTITY_FIELD_COL  1
.eqv MAPA1_FLAT_ENTITY_FIELD_ROW  2

# .include "MAPA1_defs.s"

# Formato flat: cada entidade ocupa type,col,row.
# Iteração típica:
#   la   t1, MAPA1_ENTIDADES_FLAT
#   li   t2, MAPA1_FLAT_NUM_ENTIDADES
# loop_ent:
#   beqz t2, done_ent
#   lbu  t3, MAPA1_FLAT_ENTITY_FIELD_TYPE(t1)
#   lbu  t4, MAPA1_FLAT_ENTITY_FIELD_COL(t1)
#   lbu  t5, MAPA1_FLAT_ENTITY_FIELD_ROW(t1)
#   addi t1, t1, MAPA1_FLAT_ENTITY_SIZE_BYTES
#   addi t2, t2, -1
#   j    loop_ent
# done_ent:

MAPA1_ENTIDADES_FLAT: .byte
    MAPA1_ENTITY_TYPE_PLAYER, 2, 11,
    MAPA1_ENTITY_TYPE_INIMIGO1, 10, 11,
    MAPA1_ENTITY_TYPE_INIMIGO1, 22, 11
