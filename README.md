# dotfiles
My dotfiles (neovim, git, zsh, installs etc.) for MacOS only as of now.

> Attention : The bootstrapping script has not yet been tested!

## Setup 

First setup homebrew
```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/luisenglaender/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

Then install git using brew
```sh
brew install git
```

and clone this repo (preferably to `$HOME/.dotfiles`)
```sh
git clone https://github.com/yesoer/dotfiles.git
```

You can now run the `bootstrap.sh` to finalize the install.

## References

[Druckdevs](https://github.com/druckdev) [dotfiles](https://github.com/druckdev/dotfiles) are always a hoot.
I stole your glog script.
