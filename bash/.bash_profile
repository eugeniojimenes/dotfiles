[[ -f ~/.bashrc ]] && . ~/.bashrc

# Private env vars (API keys, work-only settings) live outside this public repo.
# Guarded: fresh machine has no ~/.private/envs yet, and unguarded `source` prints
# "No such file or directory" on every login.
[[ -f ~/.private/envs ]] && . ~/.private/envs # INFO: replace with your own path of private envs

# Guarded so nested login shells (`bash -l`, tmux login shells, su -) don't prepend
# same entry again. Hit 3 copies before this check.
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac
