#!/usr/bin/env bash

rm ${HOME}/.zshenv 2> /dev/null
ln -s ${PWD}/zsh/.zshenv ${HOME}/.zshenv
