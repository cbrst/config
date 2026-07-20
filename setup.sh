#!/usr/bin/env bash

# One utility for provisioning dependencies and linking this dotfiles repo into
# XDG_CONFIG_HOME. Keep package manifests and config actions in this file so a
# new machine has a single setup entry point.

set -euo pipefail

# Resolve the repo root from the script location so setup can be run elsewhere.
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="${script_dir}"
confdir="${XDG_CONFIG_HOME:-${HOME}/.config}"

# Format codes keep status output readable without hiding command output.
bold_text="\033[1;34m"
warn_text="\033[1;33m"
reset_text="\033[0m"

# Dependency installer options are populated by parse_install_args.
dry_run=0
check_only=0
include_optional=0
platform=""
manager=""

# These macOS commands are expected from macOS or Apple's Command Line Tools.
# They are checked, not installed through Homebrew, to avoid shadowing system
# components with duplicate Brew-managed versions.
macos_system_commands=(
	bash
	curl
	git
	make
	zsh
)

# These Homebrew formulae are tools this repo expects from Homebrew on macOS,
# avoiding packages that would duplicate macOS or Command Line Tools commands.
brew_formulae=(
	bat
	cmake
	eza
	fastfetch
	fd
	ffmpeg
	fzf
	go
	jq
	lazygit
	lua
	neovim
	node
	pkg-config
	python
	ripgrep
	rustup
	starship
	thefuck
	tmux
	unzip
	webp
	yt-dlp
	zoxide
)

# Homebrew casks cover the GUI apps referenced by macOS-specific configs.
brew_casks=(
	ghostty
	karabiner-elements
	wezterm
)

# Arch package names differ slightly from Homebrew, but official repositories
# are preferred so the main Linux path has one dependable source.
arch_packages=(
	bash
	bat
	base-devel
	cmake
	curl
	eza
	fastfetch
	fd
	ffmpeg
	fzf
	git
	go
	ghostty
	jq
	lazygit
	libwebp
	lua
	neovim
	nodejs
	npm
	pkgconf
	python
	ripgrep
	rustup
	starship
	thefuck
	tmux
	unzip
	wezterm
	yt-dlp
	zoxide
	zsh
)

# AUR packages are isolated for future use because not every Arch system has an
# AUR helper and some users prefer to review AUR builds manually.
arch_aur_packages=(
)

# Optional packages support configured editor lint/format workflows.
brew_optional_formulae=(
	markdownlint-cli
	prettier
)

# Optional Arch packages mirror known official-repository names.
arch_optional_packages=(
	markdownlint-cli
	prettier
)

usage() {
	# Help lives in the utility so it remains useful before configs are linked.
	cat <<'EOF'
Usage: ./setup.sh [command] [options] [configs...]

Commands:
  install       Install required dependencies for this repo.
  check         Print missing required dependencies without installing.
  link          Link configs into XDG_CONFIG_HOME. This is the default command.
  pull          Move existing configs into the repo, then link them back.
  unlink        Remove linked configs from XDG_CONFIG_HOME.
  all           Install dependencies, then link configs.
  help          Show this help text.

Install options:
  --check       Print missing packages without installing.
  --dry-run     Print install commands without running them.
  --optional    Include optional formatter/linter packages.

Examples:
  ./setup.sh
  ./setup.sh all --optional
  ./setup.sh install --dry-run
  ./setup.sh link nvim zsh tmux
  ./setup.sh unlink
EOF
}

info() {
	# Prefix status lines consistently so phases are easy to scan.
	printf "\n${bold_text}=>${reset_text} %s\n" "$1"
}

warn() {
	# Warnings are non-fatal unless the caller exits afterward.
	printf "${warn_text}warning:${reset_text} %s\n" "$1" >&2
}

run() {
	# Dry-run mode prints the exact install command that would be executed.
	if [[ ${dry_run} -eq 1 ]]; then
		printf 'dry-run:'
		printf ' %q' "$@"
		printf '\n'
		return
	fi

	"$@"
}

command_exists() {
	# command -v is portable across the shells likely to launch this script.
	command -v "$1" >/dev/null 2>&1
}

config_names() {
	# Shell globbing gives us a BSD/macOS and Linux friendly top-level dir list.
	local path

	for path in "${repo_root}"/*; do
		if [[ -d "${path}" ]]; then
			basename "${path}"
		fi
	done
}

target_configs() {
	# If config names are provided, operate on those; otherwise use every module.
	if [[ $# -gt 0 ]]; then
		printf '%s\n' "$@"
	else
		config_names
	fi
}

confirm() {
	# Prompts default to no so accidental overwrites are hard to trigger.
	local prompt=$1
	local reply

	read -r -n 1 -p "${prompt} (y/n) " reply
	printf '\n'
	[[ "${reply}" == "y" || "${reply}" == "Y" ]]
}

remove_path() {
	# Centralizing removal keeps the one intentionally destructive action visible.
	local path=$1

	if [[ -L "${path}" || -f "${path}" ]]; then
		rm -- "${path}"
	elif [[ -d "${path}" ]]; then
		rm -r -- "${path}"
	fi
}

run_module_setup() {
	# Some modules need extra setup beyond linking, such as zsh and ghostty.
	local name=$1
	local hook="${repo_root}/${name}/setup.sh"

	if [[ -x "${hook}" ]]; then
		info "Running special setup for ${name}"
		(cd "${repo_root}" && "${hook}")
	fi
}

link_config() {
	# Link a module into XDG_CONFIG_HOME after asking before replacement.
	local name=$1
	local source="${repo_root}/${name}"
	local target="${confdir}/${name}"

	if [[ ! -d "${source}" ]]; then
		warn "unknown config: ${name}"
		return 1
	fi

	mkdir -p -- "${confdir}"
	info "Linking ${name}"

	if [[ -e "${target}" || -L "${target}" ]]; then
		if [[ -L "${target}" && "$(readlink "${target}")" == "${source}" ]]; then
			run_module_setup "${name}"
			return
		fi

		if ! confirm "Configuration for ${name} already exists. Overwrite?"; then
			return
		fi

		remove_path "${target}"
	fi

	ln -s -- "${source}" "${target}"
	run_module_setup "${name}"
}

pull_config() {
	# Pull an existing config into the repo, then replace it with a symlink.
	local name=$1
	local source="${confdir}/${name}"
	local target="${repo_root}/${name}"

	info "Pulling ${name}"

	if [[ ! -e "${source}" && ! -L "${source}" ]]; then
		warn "${name} has no existing config"
		return
	fi

	if [[ -e "${target}" || -L "${target}" ]]; then
		warn "${target} already exists; skipping pull for ${name}"
		return 1
	fi

	mv -- "${source}" "${target}"
	ln -s -- "${target}" "${source}"
}

unlink_config() {
	# Remove a config link from XDG_CONFIG_HOME without touching repo files.
	local name=$1
	local target="${confdir}/${name}"

	info "Unlinking ${name}"

	if [[ ! -e "${target}" && ! -L "${target}" ]]; then
		warn "${name} has no existing config"
		return
	fi

	if [[ ! -L "${target}" ]]; then
		warn "${target} is not a symlink; leaving it untouched"
		return 1
	fi

	rm -- "${target}"
}

detect_platform() {
	# Darwin maps directly to macOS/Homebrew for this repo.
	case "$(uname -s)" in
		Darwin)
			platform="macos"
			manager="brew"
			return
			;;
		Linux)
			;;
		*)
			warn "unsupported OS: $(uname -s)"
			exit 1
			;;
	esac

	# /etc/os-release is the standard distro identity source on Linux.
	if [[ -r /etc/os-release ]]; then
		# shellcheck disable=SC1091
		source /etc/os-release
		if [[ "${ID:-}" == "arch" || " ${ID_LIKE:-} " == *" arch "* ]]; then
			platform="arch"
			manager="pacman"
			return
		fi
	fi

	warn "unsupported Linux distro; add a package manifest for it in setup.sh"
	exit 1
}

require_manager() {
	# The installer uses one native package manager per supported platform.
	if [[ "${manager}" == "brew" ]]; then
		if ! command_exists brew; then
			warn "Homebrew is required. Install it from https://brew.sh/ and rerun this script."
			exit 1
		fi
	fi

	if [[ "${manager}" == "pacman" ]]; then
		if ! command_exists pacman; then
			warn "pacman is required for Arch-based installs."
			exit 1
		fi
	fi
}

aur_helper() {
	# Prefer common AUR helpers only when they are already installed.
	if command_exists paru; then
		printf 'paru'
	elif command_exists yay; then
		printf 'yay'
	fi
}

print_packages() {
	# A compact package report makes check mode useful before provisioning.
	local label=$1
	shift

	printf '%s:\n' "${label}"
	if [[ $# -eq 0 ]]; then
		printf '  %s\n' "(none)"
	else
		printf '  %s\n' "$@"
	fi
}

missing_brew_formulae() {
	# brew list checks installed formulae without hitting package metadata.
	local missing=()
	local package

	for package in "$@"; do
		if ! brew list --formula "${package}" >/dev/null 2>&1; then
			missing+=("${package}")
		fi
	done

	if [[ ${#missing[@]} -gt 0 ]]; then
		printf '%s\n' "${missing[@]}"
	fi
}

missing_brew_casks() {
	# Casks have their own installed-package namespace in Homebrew.
	local missing=()
	local package

	for package in "$@"; do
		if ! brew list --cask "${package}" >/dev/null 2>&1; then
			missing+=("${package}")
		fi
	done

	if [[ ${#missing[@]} -gt 0 ]]; then
		printf '%s\n' "${missing[@]}"
	fi
}

missing_commands() {
	# System prerequisites are command checks instead of package checks.
	local missing=()
	local command

	for command in "$@"; do
		if ! command_exists "${command}"; then
			missing+=("${command}")
		fi
	done

	if [[ ${#missing[@]} -gt 0 ]]; then
		printf '%s\n' "${missing[@]}"
	fi
}

warn_missing_commands() {
	# macOS/CLT tools should come from Apple, not duplicate Brew formulae.
	local missing=("$@")

	if [[ ${#missing[@]} -gt 0 ]]; then
		warn "Missing system commands: ${missing[*]}"
		warn "On macOS, install or repair Apple's Command Line Tools with: xcode-select --install"
	fi
}

missing_pacman_packages() {
	# pacman -Q checks the local package database without network access.
	local missing=()
	local package

	for package in "$@"; do
		if ! pacman -Q "${package}" >/dev/null 2>&1; then
			missing+=("${package}")
		fi
	done

	if [[ ${#missing[@]} -gt 0 ]]; then
		printf '%s\n' "${missing[@]}"
	fi
}

install_macos() {
	# Homebrew formulae cover CLI tools, compilers, runtimes, and TUI apps.
	local formulae=("${brew_formulae[@]}")
	local casks=("${brew_casks[@]}")
	local system_commands=("${macos_system_commands[@]}")

	if [[ ${include_optional} -eq 1 ]]; then
		formulae+=("${brew_optional_formulae[@]}")
	fi

	if [[ ${check_only} -eq 1 ]]; then
		# Command substitution is used instead of mapfile for macOS Bash 3.x.
		system_commands=($(missing_commands "${system_commands[@]}"))
		formulae=($(missing_brew_formulae "${formulae[@]}"))
		casks=($(missing_brew_casks "${casks[@]}"))
		if [[ ${#system_commands[@]} -gt 0 ]]; then
			print_packages "Missing macOS/CLT commands" "${system_commands[@]}"
		else
			print_packages "Missing macOS/CLT commands"
		fi
		if [[ ${#formulae[@]} -gt 0 ]]; then
			print_packages "Missing Homebrew formulae" "${formulae[@]}"
		else
			print_packages "Missing Homebrew formulae"
		fi
		if [[ ${#casks[@]} -gt 0 ]]; then
			print_packages "Missing Homebrew casks" "${casks[@]}"
		else
			print_packages "Missing Homebrew casks"
		fi
		return
	fi

	system_commands=($(missing_commands "${system_commands[@]}"))
	if [[ ${#system_commands[@]} -gt 0 ]]; then
		warn_missing_commands "${system_commands[@]}"
	fi

	info "Updating Homebrew"
	run brew update

	info "Installing Homebrew formulae"
	run brew install "${formulae[@]}"

	info "Installing Homebrew casks"
	run brew install --cask "${casks[@]}"
}

install_arch() {
	# pacman handles the primary Arch package set from official repositories.
	local packages=("${arch_packages[@]}")
	local aur_packages=("${arch_aur_packages[@]}")
	local helper

	if [[ ${include_optional} -eq 1 ]]; then
		packages+=("${arch_optional_packages[@]}")
	fi

	if [[ ${check_only} -eq 1 ]]; then
		# Package names are whitespace-free, so array assignment is safe here.
		packages=($(missing_pacman_packages "${packages[@]}"))
		aur_packages=($(missing_pacman_packages "${aur_packages[@]}"))
		print_packages "Missing pacman packages" "${packages[@]}"
		print_packages "Missing AUR packages" "${aur_packages[@]}"
		return
	fi

	info "Installing pacman packages"
	run sudo pacman -Syu --needed "${packages[@]}"

	if [[ ${#aur_packages[@]} -gt 0 ]]; then
		helper="$(aur_helper)"
		if [[ -n "${helper}" ]]; then
			info "Installing AUR packages with ${helper}"
			run "${helper}" -S --needed "${aur_packages[@]}"
		else
			warn "No AUR helper found; install these manually if needed: ${aur_packages[*]}"
		fi
	fi
}

parse_install_args() {
	# Install flags are accepted by install, check, and all subcommands.
	while [[ $# -gt 0 ]]; do
		case "$1" in
			--check)
				check_only=1
				;;
			--dry-run)
				dry_run=1
				;;
			--optional)
				include_optional=1
				;;
			--help|-h)
				usage
				exit 0
				;;
			*)
				warn "unknown install option: $1"
				usage
				exit 2
				;;
		esac
		shift
	done
}

install_dependencies() {
	# Detect and install through the primary package source for the platform.
	parse_install_args "$@"
	detect_platform
	require_manager

	info "Detected ${platform}; using ${manager}"
	case "${platform}" in
		macos)
			install_macos
			;;
		arch)
			install_arch
			;;
	esac
}

link_configs() {
	# Link requested modules, or every top-level config module by default.
	local name

	while IFS= read -r name; do
		link_config "${name}"
	done < <(target_configs "$@")
}

pull_configs() {
	# Pull requested modules, or every top-level config module by default.
	local name

	while IFS= read -r name; do
		pull_config "${name}"
	done < <(target_configs "$@")
}

unlink_configs() {
	# Unlink requested modules, or every top-level config module by default.
	local name

	while IFS= read -r name; do
		unlink_config "${name}"
	done < <(target_configs "$@")
}

main() {
	# Preserve the old no-argument behavior by making link the default command.
	local command="${1:-link}"

	if [[ $# -gt 0 ]]; then
		shift
	fi

	case "${command}" in
		install)
			install_dependencies "$@"
			;;
		check)
			check_only=1
			install_dependencies "$@"
			;;
		link)
			link_configs "$@"
			;;
		pull)
			pull_configs "$@"
			;;
		unlink)
			unlink_configs "$@"
			;;
		all)
			install_dependencies "$@"
			link_configs
			;;
		help|--help|-h)
			usage
			;;
		*)
			# Backwards compatibility: unknown commands are treated as config names.
			link_configs "${command}" "$@"
			;;
	esac
}

main "$@"
