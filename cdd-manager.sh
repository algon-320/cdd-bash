#!/usr/bin/env bash

CDDMAN_USAGE=$(cat << HEREDOC
Usage:
	cdd-manager add <target-directory> [<link-name>]
	cdd-manager remove <link-name>
	cdd-manager list
HEREDOC
)
CDDMAN_LIST_FILL=$(printf "%0.1s" -{0..80})
CDDMAN_LIST_FMT="$(tput bold)%s$(tput sgr0) %0.*s---> %s\\n"

function cdd-manager() {
  case "$1" in
  "add" )
      if [ -z "$2" ]; then
        echo "$CDDMAN_USAGE"
        return 1
      fi

      if [ ! -d "$2" ]; then
        echo "cdd-manager: <target-directory> must be a directory" 1>&2
        return 2
      fi

      local link_name
      if [ -n "$3" ]; then
        link_name="$3"
      else
        link_name=$(basename "$2")
      fi
      local target
      target=$(cd "$2" && pwd) # get full path
      ln -v -s "${target}" "${CDD_DIR}/${link_name}"
    ;;
  "remove" )
      if [ $# -lt 2 ]; then
        echo "$CDDMAN_USAGE"
        return 1
      fi

      local link_name="$2"
      rm -v "${CDD_DIR}/${link_name}"
    ;;
  "list" )
      local max_len=0
      readarray -t links < <(_cdd_search_link)
      for f in "${links[@]}"; do
        if [ $max_len -lt ${#f} ]; then
          max_len=${#f}
        fi
      done

      for f in "${links[@]}"; do
        local name p
        name=$(basename "$f")
        p=$(readlink -f "${CDD_DIR}/$f")
        printf "$CDDMAN_LIST_FMT" "$name" $((max_len - ${#f})) "$CDDMAN_LIST_FILL" "$p"
      done
    ;;
  * )
      echo "$CDDMAN_USAGE"
      return 1
    ;;
  esac
}

function _cdd-manager_completion() {
  case $COMP_CWORD in
    0 ) COMPREPLY=( add remove list );;
    1 )
      readarray -t COMPREPLY < <(compgen -W 'add remove list' "${COMP_WORDS[1]}")
      ;;
    2 )
        if [ "${COMP_WORDS[1]}" = "remove" ]; then
          readarray -t COMPREPLY < <(compgen -W '$(_cdd_search_link)' "${COMP_WORDS[2]}")
        fi
      ;;
  esac
}
complete -o dirnames -F _cdd-manager_completion cdd-manager

