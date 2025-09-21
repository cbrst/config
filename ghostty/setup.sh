#!/usr/bin/env bash

# get some additional themes not included in the default install

urls=(
    "https://raw.githubusercontent.com/rebelot/kanagawa.nvim/refs/heads/master/extras/ghostty/kanagawa-dragon"
    "https://raw.githubusercontent.com/rebelot/kanagawa.nvim/refs/heads/master/extras/ghostty/kanagawa-lotus"
    "https://raw.githubusercontent.com/rebelot/kanagawa.nvim/refs/heads/master/extras/ghostty/kanagawa-wave"
)

for url in "${urls[@]}"; do
    filename=$(basename "$url")
    if [ ! -f "${PWD}/ghostty/themes/${filename}" ]; then
        curl -o "${PWD}/ghostty/themes/${filename}" "${url}"
    fi
done
