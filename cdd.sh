#!/usr/bin/env bash
CDD_DIR="$HOME/.cdd"

# make CDD_DIR if it doesn't exist
if [ ! -d "$CDD_DIR" ]; then
  mkdir -v "$CDD_DIR"
fi

function _cdd_search_link() {
  find "$CDD_DIR" -type l -printf '%f\n'
}

function cdd() {
  CDPATH="$CDD_DIR" cd -P "$@" > /dev/null || return
}

function _cdd_completion() {
  case $COMP_CWORD in
  1 )
    readarray -t COMPREPLY < <(compgen -W '$(_cdd_search_link)' "${COMP_WORDS[1]}")
    ;;
  * ) return 0 ;;
  esac
}
complete -o dirnames -F _cdd_completion cdd

