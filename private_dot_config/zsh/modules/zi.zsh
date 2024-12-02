#--------------------------------------------------------------------#
#               basic zinit config, install and others               #
#--------------------------------------------------------------------#
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
alias zi=zinit

#--------------------------------------------------------------------#
#                completions config and load compinit                #
#--------------------------------------------------------------------#
# we need to load compinit early, which would solve some of other plugins 
zi ice blockf atpull'zinit creinstall -q .'
zi light zsh-users/zsh-completions
zi snippet OMZL::completion.zsh

autoload -Uz compinit && compinit

#--------------------------------------------------------------------#
#                         Oh my zsh plugins                          #
#--------------------------------------------------------------------#
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

zi ice if"[[ \"$(whence -p fzf)\" ]]"
zi snippet OMZP::fzf

#--------------------------------------------------------------------#
#              syntax-highlighting and autosuggestions               #
#--------------------------------------------------------------------#
zi light zsh-users/zsh-syntax-highlighting
zi light zsh-users/zsh-autosuggestions 

#--------------------------------------------------------------------#
#                   shell integration for wezterm                    #
#--------------------------------------------------------------------#
zi ice if"[[ \"${TERM_PROGRAM}\" == \"WezTerm\" ]]"
zi snippet "https://raw.githubusercontent.com/wez/wezterm/main/assets/shell-integration/wezterm.sh"

#--------------------------------------------------------------------#
#                               themes                               #
#--------------------------------------------------------------------#
if [[ $(whence -p starship) ]]; then
    eval "$(starship init zsh)"
else
    themes
    zi ice depth"1" atload"[[ ! -f ~/.p10k.zsh ]] && p10k configure || source ~/.p10k.zsh"
    zi light romkatv/powerlevel10k
fi

#--------------------------------------------------------------------#
#                               zoxide                               #
#--------------------------------------------------------------------#
zi ice if"[[ \"$(whence -p zoxide)\" ]]"
eval "$(zoxide init zsh --cmd cd)"

