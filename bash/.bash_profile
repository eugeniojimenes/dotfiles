[[ -f ~/.bashrc ]] && . ~/.bashrc

# Guarded so nested login shells (`bash -l`, tmux login shells, su -) don't prepend
# same entry again. Hit 3 copies before this check.
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac
