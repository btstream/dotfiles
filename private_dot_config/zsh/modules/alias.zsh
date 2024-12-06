#--------------------------------------------------------------------#
#                      use bat to support more                       #
#--------------------------------------------------------------------#
if [[ "$(whence -p bat)" ]]; then
    export BAT_THEME=OneHalfDark
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    export MANROFFOPT="-c"
    alias more="bat"
fi

#--------------------------------------------------------------------#
#                             youtube-dl                             #
#--------------------------------------------------------------------#
if [[ "$(whence -p youtube-dl)" ]]; then
    alias youtube-dl="youtube-dl -f \
'bestvideo[ext=mp4,height<=720]+bestaudio[ext=m4a]/\
bestvideo[ext=mp4,height<=480]+bestaudio[ext=m4a]/\
best[ext=mp4,height<=480]/best' --proxy http://127.0.0.1:1081 \
--external-downloader aria2c --external-downloader-args '-x 10'"
fi

#--------------------------------------------------------------------#
#                use lsd/exa to replace ls, lsd first                #
#--------------------------------------------------------------------#
if [[ "$(whence -p lsd)" ]]; then
    alias ls="lsd"
elif [[ "$(whence -p exa)" ]]; then
    alias ls="exa --time-style long-iso"
fi
alias ll="ls -lh"
alias la="ls -lha"

#--------------------------------------------------------------------#
#                           set nvim alias                           #
#--------------------------------------------------------------------#
if [[ "$(whence -p nvim)" ]]; then

    # set TERM to wezterm if run in WezTerm when run neovim
    if [[ "${TERM_PROGRAM}" == "WezTerm" ]]; then
        alias nvim="env TERM=wezterm nvim"
    fi

    alias v="nvim"
    alias e="nvim"
fi

#--------------------------------------------------------------------#
#                           set yay alias                            #
#--------------------------------------------------------------------#
if [[ "$(whence -p paru)" && "$(whence -p yay)" == "" ]]; then
    alias yay="paru"
fi


#--------------------------------------------------------------------#
#                               zoxide                               #
#--------------------------------------------------------------------#
if [[ "$(whence -p zoxide)" ]]; then
    eval "$(zoxide init zsh --cmd cd)"
fi

