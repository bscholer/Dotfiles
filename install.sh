#!/usr/bin/env bash
LOG="${HOME}/logs/dotfile-installer.log"
GITHUB_USER="bscholer"
GITHUB_REPO="dotfiles"
USER_GIT_AUTHOR_NAME="Ben Scholer"
USER_GIT_AUTHOR_EMAIL="github@benscholer.com"
DIR="${HOME}/.dotfiles"
PROGRAMS=("git" "zsh" "vim" "sl" "fontconfig" "htop" "curl" "wget")
INSTALL_NODE=true
INSTALL_NEOVIM=true
package_manager=""
export TERM=${TERM:-xterm-256color}
for var in "$@"
do
  if [ "$var" = "--no-node" ]; then
    INSTALL_NODE=false
    _info "Skipping Node Installation"
  fi
  if [ "$var" = "--no-neovim" ]; then
    INSTALL_NEOVIM=false
    _info "Skipping Neovim Installation"
  fi
done

mkdir -p "${LOG%/*}" && touch "$LOG"

# Check if running on Android
is_android=false
if [[ "$(uname -o)" == "Android" ]]; then
  is_android=true
fi

rainbow() {
  local message=$@
  local length=${#message}
  local colors=(1 2 3 4 5 6)
  local color_index=0

  for ((i=0; i<$length; i++)); do
    local char=${message:$i:1}
    if $is_android; then
      printf "%s" "$char"
    else
      printf "$(tput setaf ${colors[$color_index]})%s" "$char"
    fi
    ((color_index++))
    if ((color_index == ${#colors[@]})); then
      color_index=0
    fi
  done
  if ! $is_android; then
    printf "$(tput sgr0)\n"
  else
    printf "\n"
  fi
}

_intro() {
  rainbow "🐧 ******** bscholer terminal setup script ******** 🐧"
  echo ""
}

_finish() {
  rainbow "🎉 Installation complete! Enjoy the terminal! 🎉"
  echo ""
}

_info() {
  echo "$(date) INFO:  $@" >> "$LOG"
  if $is_android; then
    printf "%s...%s\n" "INFO: " "$@"
  else
    printf "$(tput setaf 4)%s...$(tput sgr0)\n" "$@"
  fi
}

_process() {
  echo "$(date) PROCESSING:  $@" >> "$LOG"
  if $is_android; then
    printf "%s...%s\n" "PROCESSING: " "$@"
  else
    printf "$(tput setaf 6)%s...$(tput sgr0)\n" "$@"
  fi
}

_success() {
  local message=$@
  if $is_android; then
    printf "✓ Success: %s\n" "$message"
  else
    printf "%s" "$(tput setaf 2)✓ Success: "
    rainbow "$message"
    printf "$(tput sgr0)\n"
  fi
}

_warning() {
  echo "$(date) WARNING:  $@" >> "$LOG"
  if $is_android; then
    printf "⚠ Warning: %s!\n" "$@"
  else
    printf "$(tput setaf 3)⚠ Warning:$(tput sgr0) %s!\n" "$@"
  fi
}

download_and_source_scripts() {
  if [ -d "./components" ]; then
    _process "Using local installer script files from the components directory..."
    for script_name in ./components/*; do
      _process "  → Sourcing ${script_name}"
      source "${script_name}"
    done
  else
    local script_base_url="https://api.github.com/repos/bscholer/dotfiles/contents/components"

    local python_command=$(command -v python || command -v python3)

    _process "Fetching installer script files list from the repository..."
    if [[ -z $python_command ]]; then
      _warning "Python is not installed or not in the PATH. Please install Python and make sure it's in your PATH."
      return 1
    fi

    local installer_scripts=$(curl -s "${script_base_url}" | $python_command -c "import sys, json; print('\n'.join([item['name'] for item in json.load(sys.stdin)]))")

    # Create a temporary directory to store the scripts
    local temp_dir=$(mktemp -d)

    _process "Downloading and sourcing script files in temporary directory..."
    for script_name in ${installer_scripts}; do
      _process "  → Downloading and sourcing ${script_name}"
      local raw_script_url="https://raw.githubusercontent.com/bscholer/dotfiles/master/components/${script_name}"
      wget --quiet -O "${temp_dir}/${script_name}" "${raw_script_url}"
      source "${temp_dir}/${script_name}"
    done

    # Remove the temporary directory
    rm -r "${temp_dir}"
  fi
}

install() {
  _intro

  download_and_source_scripts

  package_manager=$(detect_package_manager)
  install_programs
  install_lazygit
  install_lazydocker
  install_ohmyzsh
  install_zsh_plugins

  if [ "$INSTALL_NEOVIM" = true ]; then
    install_neovim
  fi
  install_nvchad

  install_colorls
  if [ "$INSTALL_NODE" = true ]; then
    install_node
  fi
  install_ruby
  install_go
  install_gotop

  install_fonts
  install_powerlevel10k

  download_dotfiles
  link_dotfiles

  run_mason_install_all
  run_lazy_install

  #install_crontab
  setup_git_authorship
  generate_ssh_key
  set_default_shell

  _finish

  cd ~
  zsh
}

install
