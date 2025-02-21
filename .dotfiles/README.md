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
    - Configure digital clock
      - Time format "ddd d MMM"
    - Taskbar
      - Pins
      - Ungroup
- Dolphin
  - Remove folders panel (F7)
  - Toolbar
    - Add "Show in Groups" button without text
- Beeper
- Vesktop
- Nextcloud
- Browser
  - Settings
    - Sleeping tabs
    - New tab position
    - Disable browser manager sidebar
    - Search engine
  - Clean toolbar
  - Clean bookmarks
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
