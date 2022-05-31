# auto install antigen
if [[ ! -e ~/.antigen/ ]]; then
    git clone --depth 1 https://github.com/zsh-users/antigen.git ~/.antigen
fi

source ~/.antigen/antigen.zsh
antigen use oh-my-zsh

antigen bundle git
# antigen bundle command-not-found
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-completions

antigen theme romkatv/powerlevel10k
antigen apply
