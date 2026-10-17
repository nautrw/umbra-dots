# not to be executed; no shebang
# shellcheck disable=C001
# shellcheck shell=bash

ask=true # default
STYLE_BOLD="\e[1m"
STYLE_FAINT="\e[2m"
STYLE_SLANT="\e[3m"
STYLE_UNDERLINE="\e[4m"
STYLE_BLINK="\e[5m"
STYLE_INVERT="\e[7m"
STYLE_RESET="\e[0m"

STYLE_RED="\e[31m"
STYLE_GREEN="\e[32m"
STYLE_YELLOW="\e[33m"
# blue is very dark in tty so i bold it
# to make it more readable
STYLE_BLUE="${STYLE_BOLD}\e[34m"
STYLE_PURPLE="\e[35m"
STYLE_CYAN="\e[36m"
