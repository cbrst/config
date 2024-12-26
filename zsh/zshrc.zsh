#
# ZIM
#

# Download zimfw plugin manager if missing
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
	curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
		https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
fi

# Install missing modules and update ${ZIM_HOME}/init.zsh
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
	source ${ZIM_HOME}/zimfw.zsh init -q
fi

source ${ZIM_HOME}/init.zsh

#
# General options
#

setopt auto_cd

#
# History
#

export HISTFILE=${__zsh_cache_dir}/zsh_history
export HISTSIZE=2000
export SAVEHIST=${HISTSIZE}

setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify
setopt hist_ignore_space

#
# Named directories
#

hash -d h=${HOME}
hash -d c=${XDG_CONFIG_HOME}
hash -d p=${HOME}/Projects

#
# Aliases
#

(( $+commands[eza] )) && alias ls="eza --group-directories-first --icons=always --color=always --git"

#
# Bat
#

(( $+commands[bat] )) && () {
  alias cat="bat"

  function battail() {
    tail -f $1 | bat --paging=never -l log
  }

  function batdiff() {
    git diff --name-only --relative --diff-filter=d | xargs bat --diff
  }
}

#
# Completion
#

autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' completer _expand_alias _complete _approximate
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
# zstyle ':completion:*' file-list all
zstyle ':completion:*' list-dirs-first true
zstyle ':completion:*:approximate:*' max-errors 2

# zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:default' list-colors ${(s.:.)LSCOLORS}

zstyle ':completion:*:*:*:users' ignored-patterns \
	'_*' 'broadcasthost' 'daemon' 'nobody'
zstyle ':completion:*:*:*:hosts' ignored-patterns \
	'broadcasthost' 'localhost' 'github.com' 'kubernetes.docker.internal'

# formats
zstyle ':completion:*'                   format '
 %F{white}%B %d%b%f'
zstyle ':completion:*:*:*:*:corrections' format ' %F{yellow}%F{black}%K{yellow}%d%F{yellow}%K{11} %F{black}errors: %e%k%F{11}%f'
zstyle ':completion:*:*:*:*:description' format ' %F{green}%F{black}%K{green}%d%k%F{green}%f'
zstyle ':completion:*:list-prompt'       format ' %F{blue}%F{black}%K{blue}%M matches%k%F{blue}%f'
zstyle ':completion:*:messages'          format ' %F{purple}%F{black}%K{purple}%d%k%F{purple}%f'
zstyle ':completion:*:warnings'          format ' %F{red}%F{black}%K{red}no matches found%k%F{red}%f'

_fzf_comprun() {
	local command=$1
	shift

	case "${command}" in
		cd) fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
		export|unset) fzf --preview "eval 'echo \$'{}" "$@" ;;
		ssh) fzf --preview 'dig {}' "#@" ;;
		cat|bat) fzf --preview 'bat -n --color=always {}' "$@" ;;
		*) fzf --preview '${__zsh_config_dir}/utils/fzf-preview.sh {}' "$@" ;;
	esac
}

#
# Fuck
#

(( $+commands[thefuck] )) && eval $(thefuck --alias)

#
# Zoxide
#

(( $+commands[zoxide] )) && eval "$(zoxide init --cmd z zsh)"
# source ${ZDOTDIR}/zoxide.zsh
