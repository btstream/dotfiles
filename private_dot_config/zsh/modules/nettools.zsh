#########################
# tools for network
########################
PROXY_HOST="127.0.0.1"
if [[ $(uname -r | grep -i microsoft | wc -l) -eq 1 ]]; then
    PROXY_HOST=$(cat /etc/resolv.conf | grep nameserver | cut -d ' ' -f 2)
fi

proxyset()
{

    if [[ $1 == "git" ]]; then
        git config --global http.proxy "socks5://$PROXY_HOST:1080"
        return
    fi

    if [[ $1 == "clear" ]]; then
        unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY
        git config --global --unset http.proxy
    fi

    if [[ $1 == "all" ]]; then
        proxy="http://$PROXY_HOST:1083"
    else
        proxy="http://$PROXY_HOST:1081"
    fi
    export http_proxy=$proxy
    export https_proxy=$proxy
    export HTTP_PROXY=$proxy
    export HTTPS_PROXY=$proxy
}
