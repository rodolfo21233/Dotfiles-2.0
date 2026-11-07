#!/bin/bash
LAPTOP="eDP-1"
HDMI="HDMI-A-1"

OUTPUTS=$(niri msg --json outputs)

if echo "$OUTPUTS" | jq -e "has(\"$HDMI\")" > /dev/null 2>&1; then
    # HDMI conectado
    niri msg output "$LAPTOP" off
    niri msg output "$HDMI" on
else
    # HDMI desconectado
    niri msg output "$HDMI" off
    niri msg output "$LAPTOP" on
fi
