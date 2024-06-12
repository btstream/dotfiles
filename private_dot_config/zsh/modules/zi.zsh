##############################################
#             basic zi config                #
##############################################
zi_home="${HOME}/.local/share/zi"
declare -A ZI
ZI[HOME_DIR]="${HOME}/.local/share/zi-home"

# install zi if does not exist
if [[ ! -e $zi_home ]]; then
    mkdir -pv $zi_home
    git clone https://github.com/z-shell/zi.git "${zi_home}/bin"
fi

# load zi and set zi
source "${zi_home}/bin/zi.zsh"
autoload -Uz _zi
(( ${+_comps} )) && _comps[zi]=_zi


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
