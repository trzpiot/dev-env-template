#!/bin/bash

RED_TEXT="\033[0;31m%s\033[0m"
GREEN_TEXT="\033[0;32m%s\033[0m"

required_apps=("direnv" "nix")

check_command() {
    if command -v $1 &>/dev/null; then
        printf "${GREEN_TEXT}\n" "$1 is installed"
        return 0
    else
        printf "${RED_TEXT}\n" "$1 is not installed"
        return 1
    fi
}

check_nix_flakes() {
    if nix --version 2>/dev/null | grep -qE "2\.(([4-9]|[1-9][0-9]+)\.[0-9]+|[1-9][0-9]+\.[0-9]+)|[3-9]\.[0-9]+\.[0-9]+|[1-9][0-9]+\.[0-9]+\.[0-9]+"; then
        if nix config show --json 2>/dev/null | grep -qE "experimental-features\s*=\s*.*\bflakes\b.*"; then
            printf "${GREEN_TEXT}\n" "Nix Flakes are enabled"
            return 0
        else
            printf "${RED_TEXT}\n" "Nix Flakes are not enabled"
            return 1
        fi
    else
        printf "${RED_TEXT}\n" "Nix version is below 2.4, Flakes are not supported"
        return 1
    fi
}

for app in "${required_apps[@]}"; do
    check_command "$app"
    invalid_components+=$?
done

if command -v nix &>/dev/null; then
    check_nix_flakes
    invalid_components+=$?
fi

if [ $invalid_components -gt 0 ]; then
    printf "\n${RED_TEXT}\n" "error: Please install/configure the missing component(s) and try again."
    exit 1
fi

contexts=("Java" "Rust" "Web (Node.js + Bun + Playwright)")

printf "\n%s\n" "Please select a context (Press 'q' to quit):"

select_context() {
    ESC=$(printf "\033")
    cursor_blink_on() { printf "$ESC[?25h"; }
    cursor_blink_off() { printf "$ESC[?25l"; }
    cursor_to() { printf "$ESC[$1;${2:-1}H"; }
    print_context() { printf "    $1 "; }
    print_selected() { printf "  ● $1"; }
    get_cursor_row() {
        IFS=';' read -sdR -p $'\E[6n' ROW COL
        echo ${ROW#*[}
    }
    key_input() {
        local key
        IFS= read -rsn1 key 2>/dev/null >&2
        if [[ $key = "" ]]; then echo enter; fi
        if [[ $key = $'\x1b' ]]; then
            read -rsn2 key
            if [[ $key = "[A" ]]; then echo up; fi
            if [[ $key = "[B" ]]; then echo down; fi
        fi
        if [[ $key = "q" ]]; then echo quit; fi
    }

    for opt; do printf "\n"; done

    local lastrow=$(get_cursor_row)
    local startrow=$(($lastrow - $#))

    trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
    cursor_blink_off

    local selected=0
    while true; do
        local idx=0
        for opt; do
            cursor_to $(($startrow + $idx))
            if [ $idx -eq $selected ]; then
                print_selected "$opt"
            else
                print_context "$opt"
            fi
            ((idx++))
        done

        case $(key_input) in
        enter) break ;;
        up)
            ((selected--))
            if [ $selected -lt 0 ]; then selected=$(($# - 1)); fi
            ;;
        down)
            ((selected++))
            if [ $selected -ge $# ]; then selected=0; fi
            ;;
        esc | quit)
            cursor_to $lastrow
            cursor_blink_on
            exit 0
            ;;
        *) ;;
        esac
    done

    cursor_to $lastrow
    printf "\n"
    cursor_blink_on

    return $selected
}

map_context() {
    case $1 in
    0) echo "java" ;;
    1) echo "rust" ;;
    2) echo "nodejs+bun+playwright" ;;
    esac
}

select_context "${contexts[@]}"
choice=$(map_context $?)

read -p "Enter a path (Default: ${choice}-template): " custom_path

if [ -z "$custom_path" ]; then
    custom_path=${choice}-template
fi

mkdir -p ${custom_path}
curl -s -L https://github.com/trzpiot/dev-env-template/archive/refs/heads/${choice}.tar.gz | tar xz -C ${custom_path} --strip-component 1

printf "\n${GREEN_TEXT}" "Template '${choice}' downloaded to path '${custom_path}'."

cd ${custom_path}
direnv allow

printf "\n${GREEN_TEXT}" "direnv allowed."

if [ -d .git ]; then
    git add flake.nix nix
    printf "${GREEN_TEXT}" "Necessary template files for Nix Flakes added to Git."
fi

printf "\n"
