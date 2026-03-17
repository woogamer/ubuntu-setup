#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "========================================="
echo "  Ubuntu 24.04 환경 설정 스크립트"
echo "========================================="

# --- 1. 기본 도구 설치 ---
echo "[1/13] 기본 패키지 설치..."
sudo apt update
sudo apt install -y \
  git git-lfs vim tmux sqlite3 curl ca-certificates gnupg \
  apt-transport-https p7zip-full flameshot flatpak \
  xclip xdotool xvfb zenity alsa-tools gh et

# --- 2. 한글 환경 ---
echo "[2/13] 한글 환경 설치..."
sudo apt install -y \
  fcitx fcitx-hangul ibus-hangul \
  fonts-nanum fonts-nanum-coding fonts-nanum-eco fonts-nanum-extra \
  fonts-noto-cjk-extra \
  language-pack-ko language-pack-ko-base \
  language-pack-gnome-ko language-pack-gnome-ko-base \
  gnome-user-docs-ko \
  hunspell-ko hunspell-en-au hunspell-en-ca hunspell-en-gb hunspell-en-za

# --- 3. NodeSource repo + Node.js 20 ---
echo "[3/13] Node.js 20 설치..."
if ! command -v node &>/dev/null; then
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo apt install -y nodejs
else
  echo "  Node.js already installed: $(node -v)"
fi

# --- 4. WineHQ ---
echo "[4/13] WineHQ 설치..."
if ! command -v wine &>/dev/null; then
  sudo dpkg --add-architecture i386
  sudo mkdir -pm755 /etc/apt/keyrings
  sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
  sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources
  sudo apt update
  sudo apt install -y --install-recommends winehq-stable winetricks
else
  echo "  Wine already installed: $(wine --version)"
fi

# --- 5. RustDesk ---
echo "[5/13] RustDesk 설치..."
if ! command -v rustdesk &>/dev/null; then
  RUSTDESK_VER=$(curl -s https://api.github.com/repos/rustdesk/rustdesk/releases/latest | grep -oP '"tag_name": "\K[^"]+')
  curl -L -o /tmp/rustdesk.deb "https://github.com/rustdesk/rustdesk/releases/download/${RUSTDESK_VER}/rustdesk-${RUSTDESK_VER}-x86_64.deb"
  sudo apt install -y /tmp/rustdesk.deb
  rm -f /tmp/rustdesk.deb
else
  echo "  RustDesk already installed"
fi

# --- 6. Flatpak 설정 ---
echo "[6/13] Flatpak 설정..."
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true

# --- 7. Docker ---
echo "[7/13] Docker 설치..."
if ! command -v docker &>/dev/null; then
  curl -fsSL https://get.docker.com | sudo sh
  sudo usermod -aG docker "$USER"
  echo "  Docker 설치됨 (재로그인 후 docker 그룹 적용)"
else
  echo "  Docker already installed: $(docker --version)"
fi

# --- 8. Starship prompt ---
echo "[8/13] Starship 설치..."
if ! command -v starship &>/dev/null; then
  curl -sS https://starship.rs/install.sh | sh -s -- -y
else
  echo "  Starship already installed: $(starship --version)"
fi

# --- 9. uv (Python 패키지 매니저) ---
echo "[9/13] uv 설치..."
if ! command -v uv &>/dev/null; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
else
  echo "  uv already installed: $(uv --version)"
fi

# --- 10. Tailscale ---
echo "[10/13] Tailscale 설치..."
if ! command -v tailscale &>/dev/null; then
  curl -fsSL https://tailscale.com/install.sh | sh
  echo "  Tailscale 설치됨 — sudo tailscale up 으로 로그인하세요"
else
  echo "  Tailscale already installed: $(tailscale --version | head -1)"
fi

# --- 11. Claude Code ---
echo "[11/13] Claude Code 설치..."
if ! command -v claude &>/dev/null; then
  npm install -g @anthropic-ai/claude-code
else
  echo "  Claude Code already installed: $(claude --version 2>/dev/null)"
fi

# --- 12. Git 설정 ---
echo "[12/13] Git 설정..."
git lfs install 2>/dev/null || true

# --- 13. Dotfiles + 폰트 복사 ---
echo "[13/13] Dotfiles 및 폰트 복사..."
if [ -d "$SCRIPT_DIR/dotfiles" ]; then
  cp "$SCRIPT_DIR/dotfiles/bashrc" ~/.bashrc 2>/dev/null && echo "  .bashrc 복사됨" || true
  cp "$SCRIPT_DIR/dotfiles/profile" ~/.profile 2>/dev/null && echo "  .profile 복사됨" || true
  cp "$SCRIPT_DIR/dotfiles/tmux.conf" ~/.tmux.conf 2>/dev/null && echo "  .tmux.conf 복사됨" || true
  cp "$SCRIPT_DIR/dotfiles/gitconfig" ~/.gitconfig 2>/dev/null && echo "  .gitconfig 복사됨" || true

  # Starship 설정
  if [ -f "$SCRIPT_DIR/dotfiles/starship.toml" ]; then
    mkdir -p ~/.config
    cp "$SCRIPT_DIR/dotfiles/starship.toml" ~/.config/starship.toml && echo "  starship.toml 복사됨" || true
  fi

  # SSH config
  if [ -f "$SCRIPT_DIR/dotfiles/ssh_config" ]; then
    mkdir -p ~/.ssh && chmod 700 ~/.ssh
    cp "$SCRIPT_DIR/dotfiles/ssh_config" ~/.ssh/config && chmod 600 ~/.ssh/config && echo "  ssh config 복사됨" || true
  fi

  # fcitx 설정
  if [ -d "$SCRIPT_DIR/dotfiles/fcitx" ]; then
    mkdir -p ~/.config
    cp -r "$SCRIPT_DIR/dotfiles/fcitx" ~/.config/fcitx && echo "  fcitx 설정 복사됨" || true
  fi

  # tmux TPM (플러그인 매니저)
  if [ ! -d ~/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && echo "  tmux TPM 설치됨" || true
  fi

  # JetBrains Mono Nerd Font
  FONT_FILES=$(ls "$SCRIPT_DIR/dotfiles/"*.ttf 2>/dev/null)
  if [ -n "$FONT_FILES" ]; then
    mkdir -p ~/.local/share/fonts
    cp "$SCRIPT_DIR/dotfiles/"*.ttf ~/.local/share/fonts/
    fc-cache -f 2>/dev/null
    echo "  JetBrains Mono Nerd Font 복사됨"
  fi
else
  echo "  dotfiles 디렉토리 없음, 건너뜀"
fi

# --- GNOME dconf 설정 ---
if [ -f "$SCRIPT_DIR/dotfiles/dconf-settings.txt" ]; then
  dconf load / < "$SCRIPT_DIR/dotfiles/dconf-settings.txt" && echo "  dconf 설정 적용됨" || true
fi

echo ""
echo "========================================="
echo "  설치 완료!"
echo "========================================="
echo "Node:      $(node -v 2>/dev/null || echo 'not found')"
echo "Git:       $(git --version 2>/dev/null || echo 'not found')"
echo "Vim:       $(vim --version 2>/dev/null | head -1 || echo 'not found')"
echo "Tmux:      $(tmux -V 2>/dev/null || echo 'not found')"
echo "Python:    $(python3 --version 2>/dev/null || echo 'not found')"
echo "Docker:    $(docker --version 2>/dev/null || echo 'not found')"
echo "uv:        $(uv --version 2>/dev/null || echo 'not found')"
echo "Starship:  $(starship --version 2>/dev/null || echo 'not found')"
echo "Claude:    $(claude --version 2>/dev/null || echo 'not found')"
echo "Wine:      $(wine --version 2>/dev/null || echo 'not found')"
echo "RustDesk:  $(rustdesk --version 2>/dev/null || echo 'not found')"
echo "Tailscale: $(tailscale --version 2>/dev/null | head -1 || echo 'not found')"
echo ""
echo "사용법: 새 머신에서 이 repo를 clone 후 실행"
echo "  git clone https://github.com/woogamer/ubuntu-setup.git"
echo "  cd ubuntu-setup && bash setup.sh"
