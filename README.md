# Ubuntu Setup

Ubuntu 24.04 LTS 환경 자동 설정 스크립트.
새 컴퓨터에서 개발 환경 + 한글 환경을 한 번에 세팅.

## 사용법

```bash
git clone https://github.com/woogamer/ubuntu-setup.git
cd ubuntu-setup
bash setup.sh
```

## 설치 항목

| 카테고리 | 패키지 |
|---|---|
| **개발도구** | git, git-lfs, nodejs 20, vim, tmux, sqlite3, python3, gh, uv |
| **AI/CLI** | Claude Code |
| **한글환경** | fcitx, fcitx-hangul, ibus-hangul, 나눔폰트, Noto CJK, hunspell-ko |
| **유틸리티** | flameshot, flatpak, xclip, xdotool, p7zip, curl |
| **인프라** | Docker, Tailscale, Eternal Terminal (et) |
| **터미널** | Starship prompt, tmux + TPM |
| **Wine** | winehq-stable, winetricks |
| **Dotfiles** | .bashrc, .profile, .tmux.conf, .gitconfig, starship.toml, ssh config, fcitx 설정 |

## 구조

```
ubuntu-setup/
├── setup.sh              # 메인 설치 스크립트
└── dotfiles/
    ├── bashrc            # .bashrc (starship, aliases)
    ├── profile           # .profile (IBus 한글 입력)
    ├── tmux.conf         # tmux 설정 (Tokyo Night 테마, TPM)
    ├── starship.toml     # Starship prompt 설정
    ├── gitconfig         # Git 기본 설정
    ├── ssh_config        # SSH 접속 설정
    ├── fcitx/            # fcitx 한글 입력기 설정
    ├── dconf-settings.txt # GNOME 데스크탑 설정
    └── *.ttf             # JetBrains Mono Nerd Font
```

## 요구사항

- Ubuntu 24.04 LTS
- sudo 권한
