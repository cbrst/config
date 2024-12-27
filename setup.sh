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
	printf "\n${bold_text}=>${reset_text} %s\n" "${1}"
}

# Check if config exists, ask if overwrite and link to the proper place
function linkConfig {
	info "Linking ${1}"
	if [ -e "${confdir}/${1}" ]; then
		read -n 1 -p "Configuration for ${1} already exists. Overwrite? (y/n) " yn
		if [[ ${yn} == "y" || ${yn} == "Y" ]]; then
			rm -r ${confdir}/${1}
			setupConfig ${1}
		else
			return
		fi
	else
		setupConfig ${1}
	fi
}

function setupConfig {
	# Link the "module" to ${confdir}
	ln -s ${PWD}/${1} ${confdir}/${1}

	# Some modules have special instruction that go beyond just linking the files
	# into ${confdir}. If a setup.sh in the directory is present, execute that
	if [ -e "${1}/setup.sh" ]; then
		info "Running special setup for ${1}"
		${1}/setup.sh
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

# Unlink config
function unlinkConfig {
	info "Unlinking ${1}"
	if [ -e "${confdir}/${1}" ]; then
		rm ${confdir}/${1}
	else
		echo "${1} has no existing config"
	fi
}

# If specific configs given as arguments, link only those,
# otherwise link everything
if [ $# -eq 0 ]; then
	for item in ${configs[@]}; do
		linkConfig ${item}
	done
else
	if [ ${1} == "pull" ]; then
		for item in ${@:2}; do
			pullConfig ${item}
		done
	elif [ ${1} == "unlink" ]; then
		if [ $# -eq 1 ]; then
			targets=${configs[@]}
		else
			targets=${@:2}
		fi
		for item in ${targets}; do
			unlinkConfig ${item}
		done
	else
		for item; do
			linkConfig ${item}
		done
	fi
fi
