# setup

pre_setup() {
  if [ -z "$FORCE_YES" ]; then
    read -p "Are you sure you want to run pre_setup? This will install packages, SKIP if you already ran this once! [y/N] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      t "Exiting.."
      return
    fi
  fi
  chmod +x $DOTFILE_PATH/setups/pre_setup.sh
  $DOTFILE_PATH/setups/pre_setup.sh
  t SUCCESS "Setup completed!"
}

reset_vimrc() {
  if [ -z "$FORCE_YES" ]; then
    read -p "Are you sure you want to reset the .vimrc? This will erase existing data, might want to create a backup! [y/N] " -n 1 -r
      echo ""
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        t "Exiting.."
        return
      fi
  fi
  t wARNING "Deleting old .vimrc"
  rm ~/.vimrc
  t WARNING "Deleting old .vim/bundle"
  rm -rf ~/.vim/bundle

  t "Linking .vimrc.."
  ln -sv $DOTFILE_PATH/.vimrc ~/.vimrc
  t "Linking successful!"

  t "Installing Vundle and plugins.."
  chmod +x $DOTFILE_PATH/setups/setups/vim_setup.sh
  $DOTFILE_PATH/setups/vim_setup.sh

  t SUCCESS "You are all set!"
}

reset_bashrc() {
  if [ -z "$FORCE_YES" ]; then
    read -p "Are you sure you want to reset the .bashrc? This will erase existing data, might want to create a backup! [y/N] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      t "Exiting.."
      return
    fi
  fi

  t WARNING "Deleting old .bashrc"
  rm ~/.bashrc
  if [[ -d "$HOME/.bash_extras" ]]; then
    t "$HOME/.bash_extras exists, deleting stock .bash files within.."
    rm ~/.bash_extras/.bash_aliases
    rm ~/.bash_extras/.bash_docker_functions
    rm ~/.bash_extras/.bash_exports
    rm ~/.bash_extras/.bash_functions
    rm ~/.bash_extras/.bash_other
    rm ~/.bash_extras/.bash_tt
  else
    t WARNING "$HOME/.bash_extras does not exist, creating.."
    t "For twork setup, be sure to create a .bash_twork file"
    mkdir ~/.bash_extras
  fi

  if [[ -d "$HOME/.bash_extras/init" ]]; then
    t "$HOME/.bash_extras/init exists, deleting stock .bash files within.."
    rm ~/.bash_extras/.bash_setup
    rm ~/.bash_extras/.bash_powerline
    rm ~/.bash_extras/.bash_exports
  else
    t WARNING "$HOME/.bash_extras/init does not exist, creating.."
    mkdir ~/.bash_extras/init
  fi
  
  t "Linking .bash_extras files.."
  ln -sv $(pwd)/.bash_extras/init/.bash_setup ~/.bash_extras/init/.bash_setup
  ln -sv $(pwd)/.bash_extras/init/.bash_powerline ~/.bash_extras/init/.bash_powerline
  ln -sv $(pwd)/.bash_extras/init/.bash_exports ~/.bash_extras/init/.bash_exports
  ln -sv $(pwd)/.bash_extras/.bash_aliases ~/.bash_extras/.bash_aliases
  ln -sv $(pwd)/.bash_extras/.bash_docker_functions ~/.bash_extras/.bash_docker_functions
  ln -sv $(pwd)/.bash_extras/.bash_functions ~/.bash_extras/.bash_functions
  ln -sv $(pwd)/.bash_extras/.bash_other ~/.bash_extras/.bash_other
  ln -sv $(pwd)/.bash_extras/.bash_tt ~/.bash_extras/.bash_tt
  t "Linking .bashrc.."
  ln -sv $(pwd)/.bashrc ~/.bashrc
  t "Linking successful, sourcing.."
  source ~/.bashrc
  if [[ ! -f "$HOME/.bash_extras/.bash_twork" ]]; then
    printf "[WARNING].bash_twork does not exist inside .bash_extras, considering creating it!\n"
  else
    printf "[INFO].bash_twork exists!\n"
    source ~/.bash_extras/.bash_twork
  fi
  t "Resetting .bashrc completed!"
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
  chmod +x $DOTFILE_PATH/setups/git_config_setup.sh
  $DOTFILE_PATH/setups/git_config_setup.sh
  t SUCCESS "Setting git config completed!"
}

reset_vscode_config() {
  if [ -z "$FORCE_YES" ]; then
    read -p "Are you sure you want to reset the vscode config? This will overwrite existing config, review vscode_setup.sh first! [y/N] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      t "Exiting.."
      return
    fi
  fi
  chmod +x $DOTFILE_PATH/setups/vscode_setup.sh
  $DOTFILE_PATH/setups/vscode_setup.sh $DOTFILE_PATH
  t "Setting vscode config completed!"
}