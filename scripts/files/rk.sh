#!/bin/zsh

# rex kill server (rex version of tk)
# --discard drops the saved sessions too, so the next start has none, as with tmux kill-server

rex server stop --discard
