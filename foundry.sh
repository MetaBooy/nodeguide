#!/bin/bash

# ======================================
# 💻 Foundry Installer Script
# Author: metabooy
# ======================================

BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

log() {
    case "$2" in
        "error") echo -e "${BOLD}${RED}❌ $1${RESET}" ;;
        "progress") echo -e "${BOLD}${YELLOW}⏳ $1${RESET}" ;;
        *) echo -e "${BOLD}${GREEN}✅ $1${RESET}" ;;
    esac
}

check_foundry_installed() {
    if command -v forge >/dev/null 2>&1; then
        log "Foundry is already installed."
        return 0
    else
        return 1
    fi
}

install_foundry() {
    log "Installing Foundry..." "progress"
    curl -L https://foundry.paradigm.xyz | bash
    export PATH="$HOME/.foundry/bin:$PATH"
    log "Running foundryup to install forge, cast, anvil..." "progress"
    foundryup
}

add_foundry_to_path() {
    if grep -q "foundry/bin" "$HOME/.bashrc" || grep -q "foundry/bin" "$HOME/.zshrc"; then
        log "Foundry path already added."
    else
        log "Adding Foundry to PATH..." "progress"
        echo 'export PATH="$HOME/.foundry/bin:$PATH"' >> "$HOME/.bashrc"
        echo 'export PATH="$HOME/.foundry/bin:$PATH"' >> "$HOME/.zshrc"
    fi
}

validate_path() {
    log "Validating current session PATH..." "progress"
    if ! command -v forge >/dev/null || ! command -v cast >/dev/null || ! command -v anvil >/dev/null; then
        log "Error: Tools not available in current session." "error"
        return 1
    fi

    log "Validating PATH for future sessions..." "progress"
    bash -c "command -v forge && command -v cast && command -v anvil" >/dev/null 2>&1 \
        && log "PATH is valid for future sessions." \
        || log "Error: PATH not valid for future shells." "error"
}

main() {
    log "Checking Foundry installation..." "progress"
    if check_foundry_installed; then
        log "Foundry already installed. Verifying PATH..."
        validate_path
    else
        install_foundry
        add_foundry_to_path
        validate_path
    fi
    log "🎉 Foundry setup complete."
}

main
