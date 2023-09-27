if [[ ! -e ~/.terminfo/ ]]; then
   mkdir ~/.terminfo
fi
if [[ $TERM_PROGRAM == "WezTerm" ]]; then
    if [[ $(find ~/.terminfo/ -name wezterm -type f | wc -l) == 0 ]]; then
        # mkdir -pv ~/.terminfo/
        tempfile=$(mktemp) \
            && curl -o $tempfile https://raw.githubusercontent.com/wez/wezterm/master/termwiz/data/wezterm.terminfo \
            && tic -x -o ~/.terminfo $tempfile \
            && rm $tempfile
    fi
fi
