#!/usr/bin/env bash

if test -d "$@"; then
  eza --tree --color=always --icons=always --git "$@" | head -200
else
  if type bat &>/dev/null; then
    bat -n --color=always "$@"
  else
    cat "$@"
  fi

fi
