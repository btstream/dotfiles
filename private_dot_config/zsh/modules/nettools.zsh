#########################
# tools for network
########################
PROXY_HOST="127.0.0.1"
SOCKS_PORT="1080"
HTTP_PORT="1081"
HTTP_PROXY_ALL_PORT="1083"
if [[ $(uname -r | grep -i microsoft | wc -l) -eq 1 ]]; then
    PROXY_HOST=$(cat /etc/resolv.conf | grep nameserver | cut -d ' ' -f 2)
    SOCKS_PORT="1082"
    HTTP_PORT="1083"
    HTTP_PROXY_ALL_PORT="1083"
fi

_set_git_proxy()
{
    git config --global http.proxy "socks5://$PROXY_HOST:$SOCKS_PORT"
}

proxyset()
{

    if [[ $1 == "git" ]]; then
        _set_git_proxy
        return
    fi

    if [[ $1 == "clear" ]]; then
        unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY
        git config --global --unset http.proxy
    fi

    if [[ $1 == "all" ]]; then
        proxy="http://$PROXY_HOST:$HTTP_PROXY_ALL_PORT"
        SOCKS_PORT=1082
    else
        proxy="http://$PROXY_HOST:$HTTP_PORT"
        SOCKS_PORT=1080
    fi
    export http_proxy=$proxy
    export https_proxy=$proxy
    export HTTP_PROXY=$proxy
    export HTTPS_PROXY=$proxy
    _set_git_proxy
}

proxyset
