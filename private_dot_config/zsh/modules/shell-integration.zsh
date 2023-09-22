if [[ $TERM_PROGRAM == "WezTerm" ]]; then
    if [[ ! -f ~/.terminfo/77/wezterm ]]; then
        # mkdir -pv ~/.terminfo/
        tempfile=$(mktemp) \
            && curl -o $tempfile https://raw.githubusercontent.com/wez/wezterm/master/termwiz/data/wezterm.terminfo \
            && tic -x -o ~/.terminfo $tempfile \
            && rm $tempfile
    fi
fi
