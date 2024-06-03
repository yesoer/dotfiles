#!/bin/bash
#
# TODO :
# - disable the terminal beep :
#   opent iterm2, from the menubar select
#   iterm2 -> preferences -> profiles -> Default -> Terminal -> Silence Bell Checkbox
# - install docker desktop (does brew work ?) :
#   wget https://desktop.docker.com/mac/main/arm64/Docker.dmg
#   sudo hdiutil attach Docker.dmg
#   sudo /Volumes/Docker/Docker.app/Contents/MacOS/install --accept-license
#   sudo hdiutil detach /Volumes/Docker
# - brave browser extension migration : 
#   bitwarden and dark
# - Alfred preferences can be migrated
#   disable spotlight shortcut with : /usr/libexec/PlistBuddy ~/Library/Preferences/com.apple.symbolichotkeys.plist -c \
#                                     "Set AppleSymbolicHotKeys:64:enabled false"
#   from : https://superuser.com/questions/1211108/remove-osx-spotlight-keyboard-shortcut-from-command-line
# - backup existing configs which will be replaced
# - automate the mkdir/symlink process
# - fill p10k wizard (if possible) :
#   { y, y, y, y, 2, 1, 2, 2, 3, 3, 4, 2, 1, 2, 2, 1, 2, n, 1, y}

setup_security() {
    # enable firewall (put 0 to disable), takes effect after restart
    sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1
}

setup_zsh() {
    # setup oh-my-zsh
    echo "get oh my zsh"
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-"$HOME"/.oh-my-zsh/custom}/themes/powerlevel10k

    cp "$TMP"/System/General/zshrc ~/.zshrc

    # check whether zsh-autosuggestions and syntax-highlighting are installed and the location is correct
    echo "get autosuggestions and highlighting"
    if test -f "$ZSH_CUSTOM/plugins/zsh-autosuggestions"; then
        git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM"/plugins/zsh-autosuggestions
    fi

    if test -f "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM"/plugins/zsh-syntax-highlighting
    fi
}

setup_sym_links() {
    mkdir -p $HOME/.config/nvim
    mkdir -p $HOME/.zsh/autoload

    ln -s $HOME/.dotfiles/.config/nvim/init.vim $HOME/.config/nvim/init.vim
    ln -s $HOME/.dotfiles/.config/nvim/coc-settings.json $HOME/.config/nvim/coc-settings.json
    ln -s $HOME/.dotfiles/.zsh/autoload/git-bb.sh $HOME/.zsh/autoload/git-bb.sh
    ln -s $HOME/.dotfiles/.zsh/autoload/git-glog.zsh $HOME/.zsh/autoload/git-glog.zsh
    ln -s $HOME/.dotfiles/.zsh/autoload/git-stash.zsh $HOME/.zsh/autoload/git-stash.zsh
    ln -s $HOME/.dotfiles/.gitconfig $HOME/.gitconfig
    ln -s $HOME/.dotfiles/.zshrc $HOME/.zshrc
}

installs() {
    brew bundle install
}

setup_neovim() {
    # Plugin manager
    curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim # plugin manager for (neo)vim

    # Install plugins
    nvim +PlugInstall
    nvim +GoInstallBinaries # vim-go requirement

    # Coc installs
    nvim -c 'CocInstall -sync coc-go|q' # coc go
    nvim -c 'CocInstall coc-clangd' # coc c
    nvim -c 'CocInstall coc-pyright' # coc pyright
    nvim -c 'CocInstall coc-rust-analyzer' # coc rust

    # GitGutter install
    mkdir -p ~/.config/nvim/pack/airblade/start
    cd ~/.config/nvim/pack/airblade/start
    git clone https://github.com/airblade/vim-gitgutter.git
    nvim -u NONE -c "helptags vim-gitgutter/doc" -c q
}

language_specific_installs() {
    # go debugger
    go install github.com/go-delve/delve/cmd/dlv@latest

    # haskell tools
    ghcup install ghc
    ghcup set ghc
    ghcup install cabal
    ghcup install hls
    cabal install hoogle
    hoogle generate
}

logins() {
    gh auth login
}

mac_config() {
    # disable autocorrect in notes app
    sudo defaults write com.apple.notes NSAutomaticSpellingCorrectionEnabled -bool false
}

main() {
    installs
    language_specific_installs

    setup_sym_links
    setup_security
    setup_zsh

    mac_config
    logins
}

TMP=$(mktemp -d)
main
sudo rm -r "$TMP"
