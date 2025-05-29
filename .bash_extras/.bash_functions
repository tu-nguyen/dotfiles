# ~/.bash_extras/.bash_functions

## functions

# Extract a file
extract () {
   if [ -f $1 ] ; then
       case $1 in
           *.tar.bz2)   tar xvjf $1    ;;
           *.tar.gz)    tar xvzf $1    ;;
           *.bz2)       bunzip2 $1     ;;
           *.rar)       unrar x $1       ;;
           *.gz)        gunzip $1      ;;
           *.tar)       tar xvf $1     ;;
           *.tbz2)      tar xvjf $1    ;;
           *.tgz)       tar xvzf $1    ;;
           *.zip)       unzip $1       ;;
           *.Z)         uncompress $1  ;;
           *.7z)        7z x $1        ;;
           *)           echo "don't know how to extract '$1'..." ;;
       esac
   else
       echo "'$1' is not a valid file!"
   fi
 }

# Display a PDF of a given man page
pdfman() {
        man -t $@ | pstopdf -i -o /tmp/$1.pdf && open /tmp/$1.pdf
}

# Print env
printv() {
  local show_limited=false
  local env_file=""
  local limit_vars=("BASE_URL" "ALLOWED_HOSTS" "ENFIRONMENT", "POSTGRES_HOST", "POSTGRES_DB")

  # Check for -l flag
  if [[ "$1" == "-l" ]]; then
    show_limited=true
  fi

  # Search for .env in current and up to two parent directories
  for dir in "." ".." "../.."; do
    if [[ -f "$dir/.env" ]]; then
      env_file="$dir/.env"
      break
    fi
  done

  if [[ -z "$env_file" ]]; then
    echo "No .env file found in current or parent directories"
    return 1
  fi

  echo "Found .env at: $env_file"

  if $show_limited; then
    for var in "${limit_vars[@]}"; do
      grep -E "^$var=" "$env_file"
    done
  else
    cat "$env_file"
  fi
}
