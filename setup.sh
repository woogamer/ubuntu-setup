#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "========================================="
echo "  Ubuntu 24.04 환경 설정 스크립트"
echo "========================================="

# --- 1. 기본 도구 설치 ---
echo "[1/7] 기본 패키지 설치..."
sudo apt update
sudo apt install -y \
  git git-lfs vim tmux sqlite3 curl ca-certificates gnupg \
  apt-transport-https p7zip-full flameshot flatpak \
  xclip xdotool xvfb zenity alsa-tools gh

# --- 2. 한글 환경 ---
echo "[2/7] 한글 환경 설치..."
sudo apt install -y \
  fcitx fcitx-hangul ibus-hangul \
  fonts-nanum fonts-nanum-coding fonts-nanum-eco fonts-nanum-extra \
  fonts-noto-cjk-extra \
  language-pack-ko language-pack-ko-base \
  language-pack-gnome-ko language-pack-gnome-ko-base \
  gnome-user-docs-ko \
  hunspell-ko hunspell-en-au hunspell-en-ca hunspell-en-gb hunspell-en-za

# --- 3. NodeSource repo + Node.js 20 ---
echo "[3/7] Node.js 20 설치..."
if ! command -v node &>/dev/null; then
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo apt install -y nodejs
else
  echo "  Node.js already installed: $(node -v)"
fi

# --- 4. WineHQ ---
echo "[4/7] WineHQ 설치..."
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

# --- 5. Flatpak 설정 ---
echo "[5/7] Flatpak 설정..."
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true

# --- 6. Git 설정 ---
echo "[6/7] Git 설정..."
git lfs install 2>/dev/null || true

# --- 7. Dotfiles 복사 ---
echo "[7/7] Dotfiles 복사..."
if [ -d "$SCRIPT_DIR/dotfiles" ]; then
  cp "$SCRIPT_DIR/dotfiles/bashrc" ~/.bashrc 2>/dev/null && echo "  .bashrc 복사됨" || true
  cp "$SCRIPT_DIR/dotfiles/profile" ~/.profile 2>/dev/null && echo "  .profile 복사됨" || true
  if [ -d "$SCRIPT_DIR/dotfiles/fcitx" ]; then
    mkdir -p ~/.config
    cp -r "$SCRIPT_DIR/dotfiles/fcitx" ~/.config/fcitx && echo "  fcitx 설정 복사됨" || true
  fi
else
  echo "  dotfiles 디렉토리 없음, 건너뜀"
fi

echo ""
echo "========================================="
echo "  설치 완료!"
echo "========================================="
echo "Node:    $(node -v 2>/dev/null || echo 'not found')"
echo "Git:     $(git --version 2>/dev/null || echo 'not found')"
echo "Vim:     $(vim --version 2>/dev/null | head -1 || echo 'not found')"
echo "Tmux:    $(tmux -V 2>/dev/null || echo 'not found')"
echo "Python:  $(python3 --version 2>/dev/null || echo 'not found')"
echo "Wine:    $(wine --version 2>/dev/null || echo 'not found')"
echo ""
echo "사용법: 새 머신에서 이 repo를 clone 후 실행"
echo "  git clone https://github.com/woogamer/ubuntu-setup.git"
echo "  cd ubuntu-setup && bash setup.sh"
