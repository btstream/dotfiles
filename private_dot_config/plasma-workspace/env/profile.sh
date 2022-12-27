if [[ ${XDG_SESSION_TYPE}=="wayland" ]]; then
    export MOZ_ENABLE_WAYLAND=1
    export SDL_VIDEODRIVER=wayland
    
    (
        while [[ "x$(pgrep xsettingsd)" == "x" ]]; do
            sleep 1
        done  
        echo "wokao"  >> /tmp/test.log
        gsettings set org.gnome.desktop.interface cursor-size 8
    )&
fi
