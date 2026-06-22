# ===========================================================================
# engine/physics.s - Fisica e colisao com mapa
# ===========================================================================

.text

# PHYSICS_GET_COLLISION_TILE
# a0 = x em pixels na tela
# a1 = y em pixels na tela
# retorna a0 = tile de colisao, ou 0 fora do mapa
PHYSICS_GET_COLLISION_TILE:
    la  t0, BG_POS
    lh  t1, 0(t0)
    lh  t2, 2(t0)
    add a0, a0, t1
    add a1, a1, t2

    bltz a0, _PHYSICS_GET_COLLISION_TILE_EMPTY
    bltz a1, _PHYSICS_GET_COLLISION_TILE_EMPTY

    srli t0, a0, TILE_W_SHIFT
    srli t1, a1, TILE_H_SHIFT

    li   t2, MAPA1_MAP_COLS
    bge  t0, t2, _PHYSICS_GET_COLLISION_TILE_EMPTY

    li   t3, MAPA1_MAP_ROWS
    bge  t1, t3, _PHYSICS_GET_COLLISION_TILE_EMPTY

    mul  t3, t1, t2
    add  t3, t3, t0
    la   t4, MAPA1_COLISAO
    add  t4, t4, t3
    lbu  a0, 0(t4)
    ret

_PHYSICS_GET_COLLISION_TILE_EMPTY:
    li a0, 0
    ret

# PHYSICS_IS_SOLID_TILE
# a0 = tile de colisao
# retorna a0 = 1 se solido, 0 caso contrario
PHYSICS_IS_SOLID_TILE:
    li t0, 1
    beq a0, t0, _PHYSICS_IS_SOLID_TILE_TRUE
    li a0, 0
    ret

_PHYSICS_IS_SOLID_TILE_TRUE:
    li a0, 1
    ret

# PHYSICS_APPLY_GRAVITY
# Stub reservado para etapa de gravidade.
PHYSICS_APPLY_GRAVITY:
    ret

# PHYSICS_RESOLVE_HORIZONTAL_MAP_COLLISION
# Stub reservado para colisao horizontal.
PHYSICS_RESOLVE_HORIZONTAL_MAP_COLLISION:
    ret

# PHYSICS_RESOLVE_VERTICAL_MAP_COLLISION
# Stub reservado para colisao vertical.
PHYSICS_RESOLVE_VERTICAL_MAP_COLLISION:
    ret
