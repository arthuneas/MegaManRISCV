#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OUT_DIR="$SCRIPT_DIR/build"
RARS_JAR="${RARS_JAR:-$SCRIPT_DIR/tools/Rars16_Custom1.jar}"

if [[ ! -f "$RARS_JAR" ]]; then
    echo "RARS nao encontrado: $RARS_JAR" >&2
    exit 1
fi

mkdir -p "$OUT_DIR"
cd "$OUT_DIR"

java -jar "$RARS_JAR" nc me ae1 a \
    dump .text MIF de1 \
    "$ROOT_DIR/fpga.s"

test -s de1_text.mif
test -s de1_data.mif

echo "Gerados:"
echo "  $OUT_DIR/de1_text.mif"
echo "  $OUT_DIR/de1_data.mif"
