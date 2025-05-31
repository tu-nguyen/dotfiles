#!/bin/bash

pre_setup() {
  if [ -z "$FORCE_YES" ]; then
    read -p "Are you sure you want to run ${GREEN}pre_setup${NC}? This will install packages, ${RED}SKIP${NC} if you already ran this once! [y/N] " -n 1 -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      t "Exiting.."
      return
    fi
  fi
  echo ""
  chmod +x $DOTFILE_PATH/setups/pre_setup.sh
  bash -i $DOTFILE_PATH/setups/pre_setup.sh
  t SUCCESS "Setup completed!"
}

reset_bashrc() {
  if [ -z "$FORCE_YES" ]; then
    read -p "Are you sure you want to ${GREEN}reset the .bashrc${NC}? This will ${RED}erase existing data${NC}, might want to create a backup! [y/N] " -n 1 -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      t "Exiting.."
      return
    fi
  fi
  echo ""
  t INFO "Deleting old .bashrc"
  rm ~/.bashrc
  if [[ -d "$HOME/.bash_extras" ]]; then
    t INFO "$HOME/.bash_extras exists, deleting stock .bash files within.."
    rm ~/.bash_extras/.bash_aliases
    rm ~/.bash_extras/.bash_docker_functions
    rm ~/.bash_extras/.bash_functions
    rm ~/.bash_extras/.bash_other
    rm ~/.bash_extras/.bash_tt
  else
    t WARNING "$HOME/.bash_extras does not exist, creating.."
    t "For twork setup, be sure to create a .bash_twork file"
    mkdir ~/.bash_extras
  fi

  if [[ -d "$HOME/.bash_extras/init" ]]; then
    t INFO "$HOME/.bash_extras/init exists, deleting stock .bash files within.."
    rm ~/.bash_extras/init/.bash_setup
    rm ~/.bash_extras/init/.bash_powerline
    rm ~/.bash_extras/init/.bash_exports
  else
    t WARNING "$HOME/.bash_extras/init does not exist, creating.."
    mkdir ~/.bash_extras/init
  fi
  
  t INFO "Linking .bash_extras files.."
  ln -sv $(pwd)/.bash_extras/init/.bash_setup ~/.bash_extras/init/.bash_setup
  ln -sv $(pwd)/.bash_extras/init/.bash_powerline ~/.bash_extras/init/.bash_powerline
  ln -sv $(pwd)/.bash_extras/init/.bash_exports ~/.bash_extras/init/.bash_exports
  ln -sv $(pwd)/.bash_extras/.bash_aliases ~/.bash_extras/.bash_aliases
  ln -sv $(pwd)/.bash_extras/.bash_docker_functions ~/.bash_extras/.bash_docker_functions
  ln -sv $(pwd)/.bash_extras/.bash_functions ~/.bash_extras/.bash_functions
  ln -sv $(pwd)/.bash_extras/.bash_other ~/.bash_extras/.bash_other
  ln -sv $(pwd)/.bash_extras/.bash_tt ~/.bash_extras/.bash_tt
  t INFO "Linking .bashrc.."
  ln -sv $(pwd)/.bashrc ~/.bashrc
  t SUCCESS"Linking successful"
  t INFO "Sourcing .bashrc.."
  source ~/.bashrc
  if [[ ! -f "$HOME/.bash_extras/.bash_twork" ]]; then
    t WARNING ".bash_twork does not exist inside .bash_extras, considering creating it!"
  else
    t SUCCESS".bash_twork exists!"
    source ~/.bash_extras/.bash_twork
  fi
  t SUCCESS "Resetting .bashrc completed!"
}

reset_vimrc() {
  if [ -z "$FORCE_YES" ]; then
    read -p "Are you sure you want to ${GREEN}reset the .vimrc${NC}? This will ${RED}erase existing data${NC}, might want to create a backup! [y/N] " -n 1 -r
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        t "Exiting.."
        return
      fi
  fi
  echo ""
  t WARNING "Deleting old .vimrc"
  rm ~/.vimrc
  t WARNING "Deleting old .vim/bundle"
  rm -rf ~/.vim/bundle

  t "Linking .vimrc.."
  ln -sv $DOTFILE_PATH/.vimrc ~/.vimrc
  t "Linking successful!"

  t "Installing Vundle and plugins.."
  chmod +x $DOTFILE_PATH/setups/vim_setup.sh
  bash -i $DOTFILE_PATH/setups/vim_setup.sh

  t SUCCESS "You are all set!"
}

reset_git_config() {
  if [ -z "$FORCE_YES" ]; then
    read -p "Are you sure you want to ${GREEN}reset the git config${NC}? This will ${RED}overwrite existing data${NC}, review git_config_setup.sh first! [y/N] " -n 1 -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      t "Exiting.."
      return
    fi
  fi
  echo ""
  chmod +x $DOTFILE_PATH/setups/git_config_setup.sh
  $DOTFILE_PATH/setups/git_config_setup.sh
  t SUCCESS "Setting git config completed!"
}

reset_vscode_config() {
  if [ -z "$FORCE_YES" ]; then
    read -p "Are you sure you want to ${GREEN}reset the vscode config${NC}? This will ${RED}overwrite existing config${NC}, review vscode_setup.sh first! [y/N] " -n 1 -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      t "Exiting.."
      return
    fi
  fi
  echo ""
  chmod +x $DOTFILE_PATH/setups/vscode_setup.sh
  bash -i $DOTFILE_PATH/setups/vscode_setup.sh $DOTFILE_PATH
  t SUCCESS "Setting vscode config completed!"
}