
tmux -L start has-session -t start 2>/dev/null && tmux -L start attach -t start || {
    tmux -L start new-session -d -s start -n btop bash -c 'btop; exec bash';
    tmux -L start new-window -d -t start: -n lazydocker bash -c 'lazydocker; exec bash';
    tmux -L start attach -t start;
}
