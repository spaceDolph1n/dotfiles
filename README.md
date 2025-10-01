# 🛠️ Dotfiles Setup (macOS)

My personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

---

## 🚀 Fresh Mac Setup

### 1. Install Homebrew

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

### 2. Install Packages

brew install stow git fzf zoxide starship neovim npm pnpm ripgrep gh nvm bat fd tmux

---

nvm install node  

---

### 3. Install Oh My Zsh

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

---

## 🔑 GitHub SSH Key Setup

### Generate Key

ssh-keygen -t ed25519 -C "your_email@example.com"  
pbcopy < ~/.ssh/id_ed25519.pub

### Add Key to GitHub

1. Go to [GitHub → Settings → SSH and GPG keys](https://github.com/settings/keys)  
2. Click **New SSH key**, paste the key, and save  

### Test SSH Connection

ssh -T git@github.com  

Expected output:  
Hi yourusername! You've successfully authenticated, but GitHub does not provide shell access.

### GitHub CLI Authentication

Authenticate GitHub CLI with your account:

gh auth login

- Choose GitHub.com  
- Choose SSH as the preferred protocol  
- Follow prompts to authenticate via browser or device code  

Verify authentication:

gh auth status

---

## 🧩 Install Zsh Plugins

- git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions  
- git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

---

## 📂 Clone Dotfiles

mkdir -p ~/.config  
cd ~/.config  
git clone git@github.com:yourusername/dotfiles.git  
cd dotfiles

---

## 🔗 Symlink with Stow

**Terminal & editor configs:**  

cd ~/.config/dotfiles  
stow -t ~/.config nvim tmux

**Shell and git configs:**  

stow -t ~ zsh git

> ⚡ **tmux** configuration is included here. After stowing, your plugins folder is ignored and TPM manages your plugins automatically. Press `prefix + I` inside tmux to install plugins.

---

## 🔄 Updating Dotfiles

git pull origin main  
stow -t ~/.config nvim tmux  
stow -t ~ zsh git

---

## 📋 Install List (Work in Progress)

### CLI Tools

- [ ] gh (GitHub CLI)  
- [ ] tmux  
- [ ] fzf  
- [ ] ripgrep (rg)  
- [ ] fd  
- [ ] htop  
- [ ] tree  
- [ ] wget / curl  
- [ ] bat  

### Programming

- [ ] node + npm (via nvm)  
- [ ] pnpm  
- [ ] python + pyenv  
- [ ] go  
- [ ] rust (via rustup)  

### Editors

- [ ] neovim  
- [ ] VS Code (settings sync)  

### Apps (Homebrew Cask)

- [ ] iTerm2  
- [ ] Rectangle  
- [ ] Karabiner-Elements  
- [ ] Raycast / Alfred  
- [ ] 1Password  
- [ ] Docker Desktop  
- [ ] Slack, Zoom, Discord
