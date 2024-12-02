export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
export EDITOR=nvim
export LANG=zh_CN.UTF-8
export PATH="$HOME/.local/bin/:$PATH"
if [[ $(whence -p fzf) ]]; then
    export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
        --color=fg:-1,fg+:#eeffff,bg:-1,bg+:#4a4a4a
        --color=hl:#82aaff,hl+:#89ddff,info:#ffcb6b,marker:#c3e88d
        --color=prompt:#82aaff,spinner:#c792ea,pointer:#8aaaff,header:#89ddff
        --color=border:#82aaff,label:#b2ccd6,query:#eeffff
        --border="rounded" --border-label="" --preview-window="border-rounded" --margin="1"
        --prompt="  " --marker="" --pointer="▍" --separator="─"
        --scrollbar="█" --layout="reverse"'
fi
