#!/usr/bin/env bash

# Remove existing .zshenv and create a new one
# This is the only config file that lives outside of ${XDG_CONFIG_DIR}
# ZSH has no problem living elsewhere, as long as ${ZDOTDIR} is set

rm ${HOME}/.zshenv 2> /dev/null

cat <<EOT >> ${HOME}/.zshenv
export ZDOTDIR=${HOME}/.config/zsh
[[ -f ${ZDOTDIR}/env.zsh ]] && source ${ZDOTDIR}/env.zsh
EOT

# Set an environment variable to the location of the repo
# This is used by some ZSH functions
echo "export CONF_PATH=${PWD}" >> ${PWD}/zsh/.zshenv
