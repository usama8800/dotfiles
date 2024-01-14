[ -n "$PS1" ] && source ~/.bash_profile;

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

[[ -f ~/.cargo/env ]] && source "$HOME/.cargo/env"

[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
[[ -f ~/.bash-preexec.sh && "$TERM" != "dumb" ]] && eval "$(atuin init bash --disable-up-arrow)"
