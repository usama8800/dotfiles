# Dotfiles

## Setup
- cd into `~/.dotfiles`
- `git clone --bare <url>`
- `git --git-dir=dotfiles.git/ --work-tree=$HOME checkout`
- `./setup`

## Manual things
- Plasma
  - Time format
  - Taskbar pins
- Kate
  - Session resume
  - Filesystem browser
    - Show hidden files, sorted last
  - Terminal follow
- Dolphin
  - Interface
    - Home on startup
    - Show filter bar
  - View
    - (Set default view first then do this) Remember display styles for each folder
- Beeper login
- Vesktop login
- MEGA sync settings
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
