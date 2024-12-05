#!/bin/bash
# this file contains functions, designed to be used by other scripts

detect_package_manager() {
  if command -v apt-get &> /dev/null; then
    echo "apt-get"
  elif command -v pacman &> /dev/null; then
    echo "pacman"
  elif command -v dnf &> /dev/null; then
    echo "dnf"
  elif command -v yum &> /dev/null; then
    echo "yum"
  elif command -v brew &> /dev/null; then
    echo "brew"
  elif command -v pkg &> /dev/null; then
    echo "pkg"
  else
    _warning "No supported package manager found. Please install one and try again"
    exit 1
  }
}

update_package_manager() {
  _info "Updating package manager"

  case "$(package_manager)" in
    apt-get)
      _process "Updating apt-get package manager"
      if command -v sudo &> /dev/null; then
        sudo apt-get update -y >> "$LOG" 2>&1
      else
        apt-get update -y >> "$LOG" 2>&1
      fi
      _success "Updated apt-get package manager"
      ;;
    dnf)
      _process "Updating dnf package manager"
      if command -v sudo &> /dev/null; then
        sudo dnf update -y >> "$LOG" 2>&1
      else
        dnf update -y >> "$LOG" 2>&1
      fi
      _success "Updated dnf package manager"
      ;;
    yum)
      _process "Updating yum package manager"
      if command -v sudo &> /dev/null; then
        sudo yum update -y >> "$LOG" 2>&1
      else
        yum update -y >> "$LOG" 2>&1
      fi
      _success "Updated yum package manager"
      ;;
    pacman)
      _process "Updating pacman package manager"
      if command -v sudo &> /dev/null; then
        sudo pacman -Sy >> "$LOG" 2>&1
      else
        pacman -Sy >> "$LOG" 2>&1
      fi
      _success "Updated pacman package manager"
      ;;
    zypper)
      _process "Updating zypper package manager"
      if command -v sudo &> /dev/null; then
        sudo zypper refresh >> "$LOG" 2>&1
      else
        zypper refresh >> "$LOG" 2>&1
      fi
      _success "Updated zypper package manager"
      ;;
    pkg)
      _process "Updating pkg package manager"
      if command -v sudo &> /dev/null; then
        sudo pkg update >> "$LOG" 2>&1
      else
        pkg update >> "$LOG" 2>&1
      fi
      _success "Updated pkg package manager"
      ;;
    *)
      _warning "Unsupported package manager. Skipping update."
      ;;
  esac
}

install_programs() {
  local package_manager="$(detect_package_manager)"
  if [[ -z "$package_manager" ]]; then
    _warning "No supported package manager found. Please install one and try again"
    exit 1
  fi

  _process "Installing dependencies using $package_manager"

  case "$package_manager" in
    apt-get)
      _process "Installing dependencies using apt-get package manager"
      if command -v sudo &> /dev/null; then
        sudo apt-get install -y "${PROGRAMS[@]}" >> "$LOG" 2>&1
      else
        apt-get install -y "${PROGRAMS[@]}" >> "$LOG" 2>&1
      fi
      ;;
    pacman)
      _process "Installing dependencies using pacman package manager"
      if command -v sudo &> /dev/null; then
        sudo pacman -S "${PROGRAMS[@]}" --noconfirm >> "$LOG" 2>&1
      else
        pacman -S "${PROGRAMS[@]}" --noconfirm >> "$LOG" 2>&1
      fi
      ;;
    dnf)
      _process "Installing dependencies using dnf package manager"
      if command -v sudo &> /dev/null; then
        sudo dnf install -y "${PROGRAMS[@]}" >> "$LOG" 2>&1
      else
        dnf install -y "${PROGRAMS[@]}" >> "$LOG" 2>&1
      fi
      ;;
    yum)
      _process "Installing dependencies using yum package manager"
      if command -v sudo &> /dev/null; then
        sudo yum install -y "${PROGRAMS[@]}" >> "$LOG" 2>&1
      else
        yum install -y "${PROGRAMS[@]}" >> "$LOG" 2>&1
      fi
      ;;
    brew)
      _process "Installing dependencies using brew package manager"
      brew install "${PROGRAMS[@]}" >> "$LOG" 2>&1
      ;;
    pkg)
      _process "Installing dependencies using pkg package manager"
      if command -v sudo &> /dev/null; then
        sudo pkg install -y "${PROGRAMS[@]}" >> "$LOG" 2>&1
      else
        pkg install -y "${PROGRAMS[@]}" >> "$LOG" 2>&1
      fi
      ;;
    *)
      _warning "No supported package manager found. Please install one and try again"
      exit 1
      ;;
  esac

  if [[ $? -eq 0 ]]; then
    _success "Installed: ${PROGRAMS[@]}"
  else
    _warning "Please install the following packages first, then try again: ${PROGRAMS[@]} \n" && exit
  fi

  _process "Installing trash-cli using pip"
  pip install trash-cli >> "$LOG" 2>&1
  if [[ $? -eq 0 ]]; then
    _success "Installed trash-cli using pip"
  else
    _warning "Failed to install trash-cli using pip"
  fi
}
