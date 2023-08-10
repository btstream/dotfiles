## use bat to replace more
if [[ "$(whence -p bat)" ]]; then
    export BAT_THEME=OneHalfDark
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    export MANROFFOPT="-c"
    alias more="bat"
fi

## youtube-dl scripts
if [[ "$(whence -p youtube-dl)" ]]; then
    alias youtube-dl="youtube-dl -f \
'bestvideo[ext=mp4,height<=720]+bestaudio[ext=m4a]/\
bestvideo[ext=mp4,height<=480]+bestaudio[ext=m4a]/\
best[ext=mp4,height<=480]/best' --proxy http://127.0.0.1:1081 \
--external-downloader aria2c --external-downloader-args '-x 10'"
fi

## use exa to replace ls
if [[ "$(whence -p exa)" ]]; then
    alias ls="exa --time-style long-iso"
    alias ll="ls -lh"
    alias la="ll -a"
    alias lg="ll --git"
fi

if [[ "$(whence -p nvim)" ]]; then

    # set TERM to wezterm if run in WezTerm when run neovim
    if [[ "${TERM_PROGRAM}" == "WezTerm" ]]; then
        alias nvim="env TERM=wezterm nvim"
    fi

    alias v="nvim"
    alias e="nvim"
fi
