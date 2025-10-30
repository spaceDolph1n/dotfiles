# 🛠️ macOS Dotfiles Setup

This repository contains my personal dotfiles and setup scripts for a fresh macOS installation.  
It manages shell configuration, CLI tools, GUI apps, Node.js setup, Tmux plugins, and other productivity enhancements using GNU Stow.

---

## ✅ Prerequisites

- Xcode Command Line Tools (if not already installed)

```bash
xcode-select --install
```

- [Homebrew](https://brew.sh/)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

---

## 🛠️ Package & App Installation

### CLI Tools

```bash
brew install bash bat eza fd fzf gh lazygit neovim nvm pnpm ripgrep starship stow tmux zoxide btop yazi
```

### Custom Formulae

```bash
brew install felixkratz/formulae/borders
brew install felixkratz/formulae/sketchybar
```

### GUI Apps

```bash
brew install --cask 1password aerospace hiddenbar homerow iina kap keka linear-linear notion-calendar notion-mail obsidian raycast spotify surfshark todoist-app zed zen zoom
```

---

## 🌐 Global npm Tools (via nvm)

Once Node.js is installed through **nvm**, install global CLI tools that rely on it.

```bash
# Ensure nvm is active
nvm use node

# Install global developer tools
npm install -g commitizen czg
```

**czg** is the command-line Commitizen adapter that provides a simple, interactive way to create conventional commits.

---

### 🧭 Verify installation

```bash
node -v
npm -v
pnpm -v
commitizen -V
czg --version
```

---

## 🐚 Shell Setup

### Oh My Zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Zsh Plugins

**Built-in Oh My Zsh plugins** do not need to be cloned manually.  
**Third-party/community plugins** must be cloned manually:

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
```

---

## 🔑 Git & GitHub Setup

### SSH Key

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
pbcopy < ~/.ssh/id_ed25519.pub
```

Add the copied key to GitHub → **Settings → SSH and GPG keys → New SSH key**

Test connection:

```bash
ssh -T git@github.com
```

Expected output:

> Hi yourusername! You've successfully authenticated, but GitHub does not provide shell access.

### GitHub CLI Authentication

```bash
gh auth login
```

Follow the prompts to authenticate.

---

## 📂 Dotfiles Setup

Clone repository:

```bash
mkdir -p ~/.config
cd ~/.config
gh repo clone spaceDolph1n/dotfiles
cd dotfiles
```

Symlink with Stow:

```bash
# Stow all configs
stow -t ~/.config .

# Stow zshrc separately into ~
stow -t ~ zshrc
```

> 💡 Stow uses symlinks, so changes in your dotfiles repo are automatically reflected.

---

## 🔌 Tmux Setup

Install Tmux Plugin Manager (TPM):

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Install plugins inside tmux:

`prefix + I` (capital I)

Or from CLI:

```bash
~/.tmux/plugins/tpm/bin/install_plugins
```

#### 🎨 Apply Theme

After installing tmux plugins, copy (or symlink) your custom theme file into the plugin directory so tmux can find it easily.

```bash
ln -sf ~/.config/dotfiles/tmux/catppuccin-kanso.tmuxtheme ~/.tmux/plugins/catppuccin-tmux/
```

---

## ⚠️ Troubleshooting

- **nvm not loaded in Zsh:** Already handled in `.zshrc`
- **Broken symlinks:** Run
  > [!code] bash
  >
  > ```bash
  > stow -R
  > ```
- **Homebrew path issues:** Run
  > [!code] bash
  >
  > ```bash
  > brew doctor
  > ```
  >
  > and follow the suggestions.
