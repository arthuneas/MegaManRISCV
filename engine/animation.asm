# ===========================================================================
# engine/animation.asm - Sistema de Animação do Mega Man
# ===========================================================================
# Controla a troca de frames dos sprites para animações
# Será implementado na etapa 2 do projeto
# ===========================================================================

.text

# ===========================================================================
# UPDATE_ANIMATION - Atualiza o frame atual da animação
# ===========================================================================
# Argumentos: (a serem definidos na etapa 2)
# Retorno: (a ser definido na etapa 2)
#
# TODO (Etapa 2): Implementar:
#   - Contador de frames para controlar velocidade da animação
#   - Troca entre sprites de animação (idle, correndo, pulando, atirando)
#   - Suporte a direção (espelhamento horizontal)
#   - Animação de dano e morte
#   - Integração com o estado do jogador (INPUT_FLAGS e estado de movimento)
# ===========================================================================
.globl UPDATE_ANIMATION
UPDATE_ANIMATION:
        ret                 # Stub - será implementado na etapa 2
