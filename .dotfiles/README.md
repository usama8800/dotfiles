# Dotfiles

## Setup
- cd into `~/.dotfiles`
- `git clone --bare <url>`
- `git --git-dir=dotfiles.git/ --work-tree=$HOME checkout`
- `./setup`

## Manual things
- Plasma
  - Mouse acceleration off
  - All Screen Panels
    - Time format
    - Taskbar pins
- Kate
  - Session resume
  - Filesystem browser
    - Show hidden files, sorted last
  - Terminal follow
- Dolphin
  - Remove folders panel (F7)
  - Toolbar
    - Add "Show in Groups" button without text
- Beeper
- Vesktop
- Nextcloud
- Browser sync
  - Bitwarden
    - Autolock never
  - Tampermonkey
  - Tab Sessions
- VSCode sync
  - Codeium
  - Wakatime
- Postgres
  - `sudo su - postgres`
  - `psql`
  - `\password`
- Python packages
  - python-dotenv
