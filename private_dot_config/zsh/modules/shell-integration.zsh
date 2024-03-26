clear_term_info() {
    find ~/.terminfo/ -name wezterm -type f -exec rm {} \; 
}
update_wezterm_terminfo() {
    if [[ $(find ~/.terminfo/ -name wezterm -type f | wc -l) == 0 ]]; then
        # mkdir -pv ~/.terminfo/
        tempfile=$(mktemp) \
            && curl -o $tempfile https://raw.githubusercontent.com/wez/wezterm/master/termwiz/data/wezterm.terminfo \
            && tic -x -o ~/.terminfo $tempfile \
            && rm $tempfile
    fi
}

if [[ ! -e ~/.terminfo/ ]]; then
   mkdir ~/.terminfo
fi
if [[ $TERM_PROGRAM == "WezTerm" ]]; then
    update_wezterm_terminfo
    export TERM=wezterm
fi
