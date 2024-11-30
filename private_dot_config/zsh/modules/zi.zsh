##############################################
#             basic zi config                #
##############################################
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

alias zi=zinit

##############################################
#             set plugins                    #
##############################################
zi load z-shell/H-S-MW
zi light z-shell/F-Sy-H

# zi ice atload'zicompinit'
zi snippet OMZL::completion.zsh
zi snippet OMZL::history.zsh
zi snippet OMZL::functions.zsh
zi snippet OMZL::misc.zsh
zi snippet OMZL::key-bindings.zsh
zi snippet OMZL::termsupport.zsh

zi snippet OMZP::gitignore
zi snippet OMZP::sudo
zi snippet OMZP::command-not-found

zi ice if"[[ \"$(whence -p pip)\" ]]"
zi snippet OMZP::pip

zi ice if"[[ \"$(whence -p zoxide)\" ]]"
ZOXIDE_CMD_OVERRIDE=cd zi snippet OMZP::zoxide

zi light zsh-users/zsh-syntax-highlighting
zi light zsh-users/zsh-autosuggestions 

zi ice blockf atload'zicompinit'
zi light zsh-users/zsh-completions

zi ice if"[[ \"${TERM_PROGRAM}\" == \"WezTerm\" ]]"
zi snippet "https://raw.githubusercontent.com/wez/wezterm/main/assets/shell-integration/wezterm.sh"

if [[ $(whence -p starship) ]]; then
    eval "$(starship init zsh)"
else
    # themes
    zi ice depth"1" atload"[[ ! -f ~/.p10k.zsh ]] && p10k configure || source ~/.p10k.zsh"
    zi light romkatv/powerlevel10k
fi
zicompinit
