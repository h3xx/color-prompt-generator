#!/bin/bash
# vi: et sts=4 sw=4 ts=4
WORKDIR=$(dirname -- "$0")
OUT=$WORKDIR/promptgen.pl

echo "Outputting to $OUT" >&2

shopt -s globstar
"$WORKDIR/squash" \
    "$WORKDIR/promptgen-main.pl" \
    "$WORKDIR"/**/*.pm \
    > "$OUT"
chmod +x -- "$OUT"
