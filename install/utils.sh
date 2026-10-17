# shellcheck shell=bash

source ./install/vars.sh

confirm_prompt() {
    local prompt="$1 [y/N] "
    local REPLY

    # sets the default response var to $REPLY
    # -n reads 1 char and doesnt need to press enter
    read -r -p "$prompt" -n 1 REPLY || return 1
    echo

    # =~ is for regex match
    # this will already return 0 if true or 1 if not true
    [[ $REPLY =~ ^[Yy]$ ]]
}

run_catch_error() {
    if ! "$@"; then
        echo "Error: Installation failed: $@" >&2
        exit 1
    fi
}

log_info() {
    echo -e "${STYLE_BLUE}[INFO] $1 ${STYLE_RESET}"
}

log_success() {
    echo -e "${STYLE_GREEN}[SUCCESS] $1 ${STYLE_RESET}"
}

log_warning() {
    echo -e "${STYLE_YELLOW}[WARN] $1 ${STYLE_RESET}"
}

log_error() {
    echo -e "${STYLE_RED}[ERROR] $1 ${STYLE_RESET}" >&2
}

log_header() {
    echo -e "${STYLE_PURPLE}==== $1 ====${STYLE_RESET}"
}

log_die() {
    log_error "$1"
    exit 1
}

command_exists() {
    # sends all output to /dev/null except in case of error
    command -v "$1" >/dev/null 2>&2
}

sudo_keepalive() {
    if [[ -n "$SUDO_KEEPALIVE_PID" ]] && kill -0 "$SUDO_KEEPALIVE_PID" 2>/dev/null; then
        # sudo keepalive is already initialized
        return 0
    fi

    log_info "Sudo is not initialized, requesting privileges for installation..."

    if ! sudo -v; then
        log_die "Failed to obtain sudo privileges. Aborting..."
    fi

    (
        while true; do
            sleep 60
            sudo -v 2>/dev/null || exit 0
        done
    ) &
    SUDO_KEEPALIVE_PID=$!

    log_success "Sudo session initialized and will be kept alive (PID: $SUDO_KEEPALIVE_PID)"
}

try() {
    local cmdstatus=0
    # $@ expands to all positional arguments
    if ! "$@"; then cmdstatus=1; fi

    while [[ $cmdstatus == 1 ]]; do
        log_error "Command '${STYLE_CYAN}$@${STYLE_RED}' has failed"
        log_info "You may need to resolve this problem manually"
        log_info "  r: Repeat this command (default)"
        log_info "  e: Exit"
        log_info "  i: Ignore and continue (may break the setup)"
        read -r -p "  You may decide what to do [R/e/i]: " choice

        case $choice in
        [eE])
            log_info "Exiting..."
            break
            ;;
        [iI])
            log_info "Ignoring and continuing..."
            cmdstatus=2
            ;;
        *) # r option
            log_info "Repeating..."
            if ! "$@"; then cmdstatus=1; fi
            ;;
        esac
    done

    case $cmdstatus in
    0) log_success "Command '${STYLE_CYAN}$@${STYLE_GREEN}' has finished successfully" ;;
    1)
        log_error "Command '${STYLE_CYAN}$@${STYLE_RED}' has failed, exiting..."
        exit 1
        ;;
    2) log_warning "Command '${STYLE_CYAN}$@${STYLE_YELLOW}' failed but is being ignored, proceed with caution" ;;
    esac
}
