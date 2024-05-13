ZK_NOTEBOOK_DIR="$HOME/my-zk"
PATH="$PATH:$HOME/.cargo/bin:$HOME/.local/bin"
## UPDATE: now is working on WSL only with ":0" value
# DISPLAY=$(awk '/nameserver / {print $2; exit}' /etc/resolv.conf 2>/dev/null):0
LIBGL_ALWAYS_INDIRECT=1
