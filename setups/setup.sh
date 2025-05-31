# setup

pre_setup() {
  if [ -z "$FORCE_YES" ]; then
    read -p "Are you sure you want to run pre_setup? This will install packages, SKIP if you already ran this once! [y/N] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo "Exiting.."
      return
    fi
  fi
  chmod +x $DOTFILE_DIR/setups/pre_setup.sh
  $DOTFILE_DIR/setups/pre_setup.sh
  echo "[INFO] Setup completed!"
}

reset_vimrc() {
  if [ -z "$FORCE_YES" ]; then
    read -p "Are you sure you want to reset the .vimrc? This will erase existing data, might want to create a backup! [y/N] " -n 1 -r
      echo ""
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Exiting.."
        return
      fi
  fi
  echo "[WARNING] Deleting old .vimrc"
  rm ~/.vimrc
  echo "[WARNING] Deleting old .vim/bundle"
  rm -rf ~/.vim/bundle

  echo "[INFO] linking .vimrc.."
  ln -sv $DOTFILE_DIR/.vimrc ~/.vimrc
  echo "[INFO] linking successful!"

  echo "[INFO] installing Vundle and plugins.."
  chmod +x $DOTFILE_DIR/setups/setups/vim_setup.sh
  $DOTFILE_DIR/setups/vim_setup.sh

  echo "You are all set!"
}

reset_bashrc() {
  if [ -z "$FORCE_YES" ]; then
    read -p "Are you sure you want to reset the .bashrc? This will erase existing data, might want to create a backup! [y/N] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo "Exiting.."
      return
    fi
  fi

  echo "[WARNING] Deleting old .bashrc"
  rm ~/.bashrc
  if [[ -d "$HOME/.bash_extras" ]]; then
    echo "[INFO] $HOME/.bash_extras exists, deleting stock .bash files within.."
    rm ~/.bash_extras/.bash_aliases
    rm ~/.bash_extras/.bash_docker_functions
    rm ~/.bash_extras/.bash_exports
    rm ~/.bash_extras/.bash_functions
    rm ~/.bash_extras/.bash_other
    rm ~/.bash_extras/.bash_tt
  else
    echo "[WARNING] $HOME/.bash_extras does not exist, creating.."
    echo "[WARNING] For twork setup, be sure to create a .bash_twork file"
    mkdir ~/.bash_extras
  fi

  if [[ -d "$HOME/.bash_extras/init" ]]; then
    echo "[INFO] $HOME/.bash_extras/init exists, deleting stock .bash files within.."
    rm ~/.bash_extras/.bash_setup
    rm ~/.bash_extras/.bash_powerline
    rm ~/.bash_extras/.bash_exports
  else
    echo "[WARNING] $HOME/.bash_extras/init does not exist, creating.."
    mkdir ~/.bash_extras/init
  fi
  
  echo "[INFO] linking .bash_extras files.."
  ln -sv $(pwd)/.bash_extras/init/.bash_setup ~/.bash_extras/init/.bash_setup
  ln -sv $(pwd)/.bash_extras/init/.bash_powerline ~/.bash_extras/init/.bash_powerline
  ln -sv $(pwd)/.bash_extras/init/.bash_exports ~/.bash_extras/init/.bash_exports
  ln -sv $(pwd)/.bash_extras/.bash_aliases ~/.bash_extras/.bash_aliases
  ln -sv $(pwd)/.bash_extras/.bash_docker_functions ~/.bash_extras/.bash_docker_functions
  ln -sv $(pwd)/.bash_extras/.bash_functions ~/.bash_extras/.bash_functions
  ln -sv $(pwd)/.bash_extras/.bash_other ~/.bash_extras/.bash_other
  ln -sv $(pwd)/.bash_extras/.bash_tt ~/.bash_extras/.bash_tt
  echo "[INFO] linking .bashrc.."
  ln -sv $(pwd)/.bashrc ~/.bashrc
  echo "[INFO] linking successful, sourcing.."
  source ~/.bashrc
  if [[ ! -f "$HOME/.bash_extras/.bash_twork" ]]; then
    printf "[WARNING].bash_twork does not exist inside .bash_extras, considering creating it!\n"
  else
    printf "[INFO].bash_twork exists!\n"
    source ~/.bash_extras/.bash_twork
  fi
  echo "[INFO] Resetting .bashrc completed!"
}

reset_git_config() {
  if [ -z "$FORCE_YES" ]; then
    read -p "Are you sure you want to reset the git config? This will overwrite existing data, review git_config_setup.sh first! [y/N] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo "Exiting.."
      return
    fi
  fi
  chmod +x $DOTFILE_DIR/setups/git_config_setup.sh
  $DOTFILE_DIR/setups/git_config_setup.sh
  echo "[INFO] Setting git config completed!"
}

reset_vscode_config() {
  if [ -z "$FORCE_YES" ]; then
    read -p "Are you sure you want to reset the vscode config? This will overwrite existing config, review vscode_setup.sh first! [y/N] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo "Exiting.."
      return
    fi
  fi
  chmod +x $DOTFILE_DIR/setups/vscode_setup.sh
  $DOTFILE_DIR/setups/vscode_setup.sh $DOTFILE_DIR
  echo "[INFO] Setting vscode config completed!"
}