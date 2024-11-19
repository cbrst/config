export ZDOTDIR=${ZDOTDIR:-${HOME}/.config/zsh}

# XDG
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-${HOME}/.config}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-${HOME}/.cache}
export XDG_DATA_HOME=${XDG_DATA_HOME:-${HOME}/.local/share}
export XDG_STATE_HOME=${XDG_STATE_HOME:-${HOME}/.local/state}
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-${HOME}/.xdg}
export XDG_PROJECTS_DIR=${XDG_PROJECTS_DIR:-${HOME}/Projects}

# Fish-like dirs
: ${__zsh_config_dir:=${ZDOTDIR:-${XDG_CONFIG_HOME:-${HOME}/.config}/zsh}}
: ${__zsh_user_data_dir:=${XDG_DATA_HOME:-${HOME}/.local/share}/zsh}
: ${__zsh_cache_dir:=${XDG_CACHE_HOME:-${HOME}/.cache}/zsh}

# Ensure dirs exist
() {
	local zdir
	for zdir in $@; do
		[[ -d "${(P)zdir}" ]] || mkdir -p -- "${(P)zdir}"
	done
} __zsh_{config,user_data,cache}_dir XDG_{CONFIG,CACHE,DATA,STATE}_HOME XDG_{RUNTIME,PROJECTS}_DIR

# Use bat as manpager
(( $+commands[bat] )) && export MANPAGER="bat -l man -p'"

# Editor
(( $+commands[nvim] )) && export EDITOR=nvim

# FZF
_fzf_opts="--height 50% --layout=reverse --border=horizontal --margin=1 --padding=1"
_fzf_opts+=" --color=bg+:#1f2335,border:#545c7e,pointer:#e0af68,hl:#bb9af7,hl+:#ff007c,info:#394b70"
_fzf_opts+=" --prompt=' ' --pointer=' ' --marker=' ' --header=' ' --info=inline:' ᰄ '"
export FZF_DEFAULT_OPTS=$_fzf_opts

# zimfw
export ZIM_HOME=${__zsh_user_data_dir}/zim
export ZIM_CONFIG_FILE=${ZDOTDIR:-${HOME}/.config/zsh}/zimrc.zsh

# PATH
export PATH=${PATH}:${HOME}/.local/bin