#!/usr/bin/env bash

wezterm start --always-new-process -- nvim ${1} & osascript -e 'tell application "WezTerm" to activate'
