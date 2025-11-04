export ZDOTDIR=${ZDOTDIR:-${HOME}/.config/zsh}

# XDG
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-${HOME}/.config}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-${HOME}/.cache}
export XDG_DATA_HOME=${XDG_DATA_HOME:-${HOME}/.local/share}
export XDG_STATE_HOME=${XDG_STATE_HOME:-${HOME}/.local/state}
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-${HOME}/.xdg}
export XDG_PROJECTS_DIR=${XDG_PROJECTS_DIR:-${HOME}/Projects}

# Homebrew
[ -f /opt/homebrew/bin/brew ] && eval $(/opt/homebrew/bin/brew shellenv)

# PATH
export PATH=${PATH}:${HOME}/.local/bin

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
_fzf_opts="--height 50% --layout=reverse"
_fzf_opts+=" --color=border:7,pointer:6,hl:6,info:6,marker:2,fg+:-1:bold,bg+:-1,hl+:6"
_fzf_opts+=" --prompt=' ' --pointer=' ' --marker=' ' --info=inline:'  '"
export FZF_DEFAULT_OPTS=$_fzf_opts

# zimfw
export ZIM_HOME=${__zsh_user_data_dir}/zim
export ZIM_CONFIG_FILE=${ZDOTDIR:-${HOME}/.config/zsh}/zimrc.zsh

# Starship
export STARSHIP_CONFIG=${XDG_CONFIG_HOME}/starship/starship.toml

# Secrets
# API keys and such. Obviously I won't put this into the repo, this needs to be created by hand:
# export ANTHROPIC_API_KEY="api_key"
[ -f ${ZDOTDIR}/secrets.zsh ] && . ${ZDOTDIR}/secrets.zsh
