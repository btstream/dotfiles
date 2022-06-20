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

zi ice atload'zicompinit'
zi snippet OMZL::completion.zsh
zi snippet OMZL::history.zsh
zi snippet OMZL::functions.zsh
zi snippet OMZL::misc.zsh
zi snippet OMZL::key-bindings.zsh

zi snippet OMZP::git
zi snippet OMZP::sudo

zi light zsh-users/zsh-syntax-highlighting
zi light zsh-users/zsh-autosuggestions 

zi ice blockf atload'zicompinit'
zi light zsh-users/zsh-completions

# themes
zi ice depth"1" atload"[[ ! -f ~/.p10k.zsh ]] && p10k configure || source ~/.p10k.zsh"
zi light romkatv/powerlevel10k

