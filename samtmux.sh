#!/usr/bin/env bash

# Directory where all your projects live
PROJECTS_DIR="$HOME/projects"

# Check dependencies
for cmd in fzf tmux; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: $cmd is not installed." >&2
    exit 1
  fi
done

# Ensure projects directory exists
if [ ! -d "$PROJECTS_DIR" ]; then
  echo "Error: $PROJECTS_DIR does not exist." >&2
  exit 1
fi

# Pick a project using fzf
PROJECT_PATH=$(find "$PROJECTS_DIR" -maxdepth 1 -mindepth 1 -type d | fzf --prompt="Select a project: ")

# Exit if no selection
[ -z "$PROJECT_PATH" ] && echo "No project selected." && exit 0

# Derive session name from directory name
PROJECT_NAME=$(basename "$PROJECT_PATH")

# Function: create a new tmux session and open nvim
create_session() {
  tmux new-session -ds "$PROJECT_NAME" -c "$PROJECT_PATH"
  # Send nvim command to the first (0) window
  tmux send-keys -t "$PROJECT_NAME":0 "nvim ." C-m
}

# Logic depending on whether tmux is already running
if [ -n "$TMUX" ]; then
  # Already inside tmux
  if tmux has-session -t "$PROJECT_NAME" 2>/dev/null; then
    tmux switch-client -t "$PROJECT_NAME"
  else
    create_session
    tmux switch-client -t "$PROJECT_NAME"
  fi
else
  # Not in tmux yet
  if tmux has-session -t "$PROJECT_NAME" 2>/dev/null; then
    tmux attach -t "$PROJECT_NAME"
  else
    create_session
    tmux attach -t "$PROJECT_NAME"
  fi
fi
