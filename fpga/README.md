# Build para a RISCV-v24 / DE1-SoC

`fpga.s` e a entrada usada para gerar as memorias da placa. Ela instala o
tratador de excecoes de `SYSTEMv24.s` por meio de `MACROSv24.s` antes de
executar o jogo. Use `main.s` diretamente no FPGRARS; o simulador inicia pelo
label `main` e nao executa o prologo anterior a ele.

## Gerar as memorias

O `Rars16_Custom1.jar` usado pela RISCV-v24 esta versionado em `fpga/tools`,
portanto o build nao depende de arquivos externos ao repositorio. Para usar
outra versao explicitamente:

```bash
RARS_JAR=/caminho/Rars16_Custom1.jar ./fpga/build.sh
```

Os arquivos ficam em:

```text
fpga/build/de1_text.mif
fpga/build/de1_data.mif
```

## Programar a placa

1. Restaure `RISC-V-v24.qar` no Quartus.
2. Substitua `de1_text.mif` e `de1_data.mif` pelos arquivos gerados.
3. Execute **Processing > Update Memory Initialization File** e gere novamente
   o arquivo de programacao, ou faca uma compilacao completa.
4. Programe a DE1-SoC, conecte VGA, teclado PS/2 e a saida de audio.
5. Use modo automatico/rapido e `SW[4:0] = 00001` para o clock de 50 MHz.
   `SW[4:0] = 00000` divide o clock por 256 e deixa o jogo muito lento.
6. `SW[6]` apenas inverte qual framebuffer e apresentado; `SW[9] = 0`
   desabilita a tela de debug.

Controles: `WASD` movem, `J` atira, `K` pula e `L` troca a habilidade.

## Audio

Musica e efeitos usam o MIDI Out assincrono (`ecall 31`) do `SYSTEMv24`. O
sintetizador da RISCV-v24 aceita ate oito notas simultaneas. O MIDI Out
sincrono (`ecall 33`) nao e usado, pois ele so retorna depois do termino da
nota e bloquearia o loop do jogo.
