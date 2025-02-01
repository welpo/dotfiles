# Dotfiles

My dotfiles. Managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Quick setup

### Full setup (new server)

```bash
sudo apt install stow && cd && rm .bashrc && git clone https://github.com/welpo/dotfiles.git && cd dotfiles && stow -t ~ */
```

### Manual installation

```bash
git clone https://github.com/welpo/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Install everything.
stow .
```
