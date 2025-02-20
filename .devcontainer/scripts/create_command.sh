#!/bin/sh
set -e

echo "🔍 Updating package list..."
apt update -y

echo "📦 Installing necessary packages..."
apt install -y openssh-client git-secrets

echo "🎨 Configuring Bash prompt..."
cat <<'EOF' >> ~/.bashrc
parse_git_branch() {
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    echo " git:($branch)"
  fi
}
export PS1='\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\[\e[1;36m\]$(parse_git_branch)\[\e[0m\]\n\$ '

alias ls='ls --color=auto'
EOF

echo "✅ create command complete!"
