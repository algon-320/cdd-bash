CDD_DIR="$HOME/.cdd"

# make CDD_DIR if it doesn't exist
if [ ! -d $CDD_DIR ]; then
  mkdir -v $CDD_DIR
fi

function _cdd_search_link() {
  find $CDD_DIR -type l -name '*' -printf '%f '
}

function cdd() {
  CDPATH="$CDD_DIR" cd -P $@ > /dev/null
}

function _cdd_completion() {
  case $COMP_CWORD in
  1 ) COMPREPLY=( `compgen -W '$(_cdd_search_link)' ${COMP_WORDS[1]}` ) ;;
  * ) return 0 ;;
  esac
}
complete -o filenames -F _cdd_completion cdd

