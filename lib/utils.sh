# shellcheck shell=bash

source ./lib/vars.sh

read_fmt() {
    local prompt="$1"
    # -n is a reference to another variable
    local -n response="$2"
    # #{var:-} syntax makes it an optional arg by defaulting to emptyu
    local readchars="${3:-}"
    local REPLY

    # printf '%s' "$prompt"
    echo -ne "${STYLE_CYAN}$prompt ${STYLE_RESET}"

    if [[ -n $readchars ]]; then
        read -r -n "$readchars" response || return 1
        printf '\n'
    else
        read -r -e response || return 1
    fi
}

ask_confirm() {
    local prompt="$1 [y/N]"

    # sets the default response var to $REPLY
    # -n reads 1 char and doesnt need to press enter
    read_fmt "$prompt" choice 1

    # =~ is for regex match
    # this will already return 0 if true or 1 if not true
    [[ $choice =~ ^[Yy]$ ]]
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

header() {
    # printf doesnt use a newline, essentially returning the string
    printf '%s' "========== $1 =========="
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

user_catch_error() {
    local cmdstatus=0
    # $@ expands to all positional arguments
    if ! "$@"; then cmdstatus=1; fi

    while [[ $cmdstatus == 1 ]]; do
        log_error "Command '${STYLE_CYAN}$@${STYLE_RED}' has failed"
        log_info "You may need to resolve this problem manually"
        log_info "  r: Repeat this command (default)"
        log_info "  e: Exit"
        log_info "  i: Ignore and continue (may break the setup)"
        ask_fmt "${STYLE_CYAN}What to do? [R/e/i] ${STYLE_RESET}" choice

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
    0) log_success "Command '${STYLE_CYAN}$*${STYLE_GREEN}' has finished successfully" ;;
    1)
        log_error "Command '${STYLE_CYAN}$*${STYLE_RED}' has failed, exiting..."
        exit 1
        ;;
    2) log_warning "Command '${STYLE_CYAN}$*${STYLE_YELLOW}' failed but is being ignored, proceed with caution" ;;
    esac
}

user_ask_exec() {
    log_info "$(header "Next Command")"
    log_info "$*"

    local execute=true

    # bash variables are global anywhere
    if ! $ask; then
        user_catch_error "$@"
        return
    fi

    while true; do
        local choice
        log_info "  y: Yes (default)"
        log_info "  e: Exit now"
        log_info "  s: Skip (may break the setup)"
        log_info "  a: Yes and don't ask again (NOT recommended)"
        read_fmt "${STYLE_CYAN}Execute? [Y/e/s/a]: ${STYLE_RESET}" choice 1

        case $choice in
            [eE])
                log_info "Exiting..."
                exit 0
                ;;
            [sS])
                log_warning "Skipping this command..."
                execute=false
                break
                ;;
            [aA])
                if ask_confirm "Are you SURE you want to do this?" \
                    && ask_confirm "Are you ABSOLUTELY SURE?"; then
                        ask=false
                        log_warning "Will not ask to run any commands..."
                        log_info "Executing command..."
                else
                    continue
                fi
                break
                ;;
            *) # yes
                log_info "Executing command..."
                break
                ;;
        esac
    done

    if $execute; then
        user_catch_error "$@"
    else
        log_warning "Skipped $*"
    fi
}
