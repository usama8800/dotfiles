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
- Dolphin
  - Remove folders panel (F7)
  - Toolbar
    - Add "Show in Groups" button without text
- Beeper
- Vesktop
- Nextcloud
- Browser
  - Bitwarden
    - Autolock never
  - Tampermonkey
  - Tab Sessions
- VSCode
  - Codeium
  - Wakatime
- Postgres
  - `sudo su - postgres`
  - `psql`
  - `\password`
- Python packages
  - python-dotenv
