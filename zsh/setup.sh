#!/usr/bin/env bash

# Set an environment variable to the location of the repo
# This is used by some ZSH functions
echo "export CONF_PATH=${PWD}" >> ${PWD}/zsh/.zshenv

# Copy .zshenv to ${HOME}
# This is the only config file that lives outside of ${XDG_CONFIG_DIR}
# ZSH has no problem living elsewhere, as long as ${ZDOTDIR} is set
rm ${HOME}/.zshenv 2> /dev/null
cp ${PWD}/zsh/.zshenv ${HOME}/.zshenv
