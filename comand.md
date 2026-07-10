# Comandos úteis

## Religar/silenciar o FluidSynth (Linux)

Se a música ficar presa tocando depois de fechar o jogo (nota sem "note off"
porque o FPGRARS foi morto antes de mandar o note-off, e o FluidSynth roda
como processo separado que não sabe disso), roda:

```bash
pkill fluidsynth; sleep 1
nohup fluidsynth -i -s -a pulseaudio -m alsa_seq /usr/share/sounds/sf2/FluidR3_GM.sf2 > ~/fluidsynth.log 2>&1 < /dev/null &
disown
sleep 2
aconnect 14:0 "$(aconnect -l | awk -F'[ :]' '/FLUID Synth/{print $2}'):0"
```

Isso mata qualquer FluidSynth preso, sobe um novo limpo e reconecta o
`Midi Through` (porta que o FPGRARS usa por padrão) nele automaticamente.

Rodar no linux

```bash
WINIT_UNIX_BACKEND=x11 ./fpgrars-linux main.s
```