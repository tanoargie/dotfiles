#!/bin/bash
answer_is_yes() {
    [[ "$REPLY" =~ ^[Yy]$ ]] \
        && return 0 \
        || return 1
}
print_error() {
    # Print output in red
    printf "\e[0;31m  [✖] $1 $2\e[0m\n"
}
print_success() {
    # Print output in green
    printf "\e[0;32m  [✔] $1\e[0m\n"
}
print_question() {
    # Print output in yellow
    printf "\e[0;33m  [?] $1\e[0m"
}
print_result() {
    [ $1 -eq 0 ] \
        && print_success "$2" \
        || print_error "$2"

    [ "$3" == "true" ] && [ $1 -ne 0 ] \
        && exit
}
execute() {
    $1 &> /dev/null
    print_result $? "${2:-$1}"
}
ask_for_confirmation() {
    print_question "$1 (y/n) "
    read -n 1
    printf "\n"
}
installing_asdf() {
  echo "Installing asdf prerequisites with Homebrew..."
  brew install coreutils curl git
  echo "Installing asdf..."
  brew install asdf
  echo "Installing asdf plugins..."
  asdf install
}
declare -a FILES_TO_SYMLINK=".zshrc .skhdrc .tmux.conf .tools-versions"
main() {

    local i=""
    local sourceFile=""
    local targetFile=""

    for i in ${FILES_TO_SYMLINK[@]}; do

        sourceFile="$(pwd)/$i"
        targetFile="$HOME/$(printf "%s" "$i" | sed "s/.*\/\(.*\)/\1/g")"

        if [ -e "$targetFile" ]; then
            if [ "$(readlink "$targetFile")" != "$sourceFile" ]; then

                ask_for_confirmation "'$targetFile' already exists, do you want to overwrite it?"
                if answer_is_yes; then
                    rm -rf "$targetFile"
                    execute "ln -fs $sourceFile $targetFile" "$targetFile → $sourceFile"
                else
                    print_error "$targetFile → $sourceFile"
                fi

            else
                print_success "$targetFile → $sourceFile"
            fi
        else
            execute "ln -fs $sourceFile $targetFile" "$targetFile → $sourceFile"
        fi

    done

    installing_asdf
}

main


