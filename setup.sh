#!/usr/bin/env bash

# Configuration target
confdir=${XDG_CONFIG_HOME:-${HOME}/.config}

# MacOS find shenanigans
if [ $(uname -s) = "Darwin" ]; then
	configs=($(find . -type d -depth 1 -not -path './\.*' -exec ls -ld {} \; | awk '{gsub("^.*/","",$9); printf "%s\n", $9}'))
else
	configs=($(find . -type d -depth 1 -printf '%p\n' -not -path './\.*'))
fi

# Format codes
bold_text="\033[1;34m"
reset_text="\033[0m"

function info {
	printf "${bold_text}=>${reset_text} %s\n" "${1}"
}

# Check if config exists, ask if overwrite and link to the proper place
function copyConfig {
	info "Linking ${1}"
	if [ -e "${confdir}/${1}" ]; then
		read -n 1 -p "Configuration for ${1} already exists. Overwrite? (y/n) " yn
		if [[ ${yn} == "y" || ${yn} == "Y" ]]; then
			rm -r ${confdir}/${1}
			ln -s ${PWD}/${1} ${confdir}/${1}
		else
			return
		fi
	else
		ln -s ${PWD}/${1} ${confdir}/${1}
	fi
}

# Pull existing config into repo
function pullConfig {
	info "Pulling ${1}"
	if [ -e "${confdir}/${1}" ]; then
		mv ${confdir}/${1} ${PWD}
		ln -s ${PWD}/${1} ${confdir}/${1}
	else
		echo "${1} has no existing config"
	fi
}

# If specific configs given as arguments, link only those,
# otherwise link everything
if [ $# -eq 0 ]; then
	for item in ${configs[@]}; do
		copyConfig ${item}
	done
else
	if [ ${1} == "pull" ]; then
		for item in ${@:2}; do
			pullConfig ${item}
		done
	else
		for item; do
			copyConfig ${item}
		done
	fi
fi
