#!/bin/bash
# BungeeCore service that manage the server in a tmux sessions.

TMUX_SOCKET="minecraft"
TMUX_SESSION="Manage"

is_manage_sessions() {
    TMUX_SESSION_LISTS=$("/usr/bin/tmux -L ${TMUX_SOCKET} list-sessions | awk '{print $1}' | sed 's/://g' | sed /${TMUX_SESSION}/d")
    return ${?}
}

is_manage_running() {
    /usr/bin/tmux -L ${TMUX_SOCKET} has-session -t ${TMUX_SESSION} > /dev/null 2>&1
    return ${?}
}

start_manage() {
    if is_manage_running; then
        echo "Server manager already running"
        return 1
    else
        echo "Starting manager server in tmux session"
        /usr/bin/tmux -L ${TMUX_SOCKET} new-session -s ${TMUX_SESSION}

        if [[ ${?} -ne 0 ]]; then
            echo "Server manager is not create!"
            return 1
        else
            SPLIT_NUM=0
            for TMUX_SESSION_NAME in ${TMUX_SESSION_LISTS}; do
                
            done
            
            return 0
        fi
    fi
}

stop_manage() {
    if ! is_manage_running; then
        echo "Server manager is not running!"
        return 1
    else
        /usr/bin/tmux -L ${TMUX_SOCKET} kill-session -s ${TMUX_SESSION}
        return 0
    fi
}

restart_manage() {
    if ! is_manage_running; then
        echo "Server manager is not running!"
        return 1
    else
        if stop_manage; then
            start_manage
            return ${?}
        else
            echo "Failed server manager restart"
            return 1
        fi
    fi
}

reload_manage() {
    /usr/bin/tmux -L ${TMUX_SOCKET} send-keys -t ${TMUX_SESSION}.0 "reload" ENTER
    return ${?}
}

attach_session() {
    if ! is_manage_running; then
        echo "Cannot attach to server manager session, server not running"
        return ${?}
    else
        /usr/bin/tmux -L ${TMUX_SOCKET} attach-session -t ${TMUX_SESSION}
        return 0
    fi
}

case "$1" in
    start)
        start_manage
        exit ${?}
        ;;
    stop)
        stop_manage
        exit ${?}
        ;;
    restart)
        restart_manage
        exit ${?}
        ;;
    reload)
        reload_manage
        exit ${?}
        ;;
    attach)
        attach_session
        exit ${?}
        ;;
    *)
        echo "Usage: ${0} {start|stop|restart|reload|attach}"
        exit 2
        ;;
esac
