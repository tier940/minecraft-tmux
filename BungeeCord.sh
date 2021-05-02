#!/bin/bash
# BungeeCord service that starts the server in a tmux session.

TMUX_SOCKET="minecraft"
TMUX_SESSION="BungeeCord"
MC_HOME="/home/mc/Servers/BungeeCord"
MC_JAR_FILE="BungeeCord.jar"
MC_MIN_RAM="128M"
MC_MAX_RAM="256M"
MC_JVM_PARAMETERS="-server"

is_server_running() {
    /usr/bin/tmux -L ${TMUX_SOCKET} has-session -t ${TMUX_SESSION} > /dev/null 2>&1
    return ${?}
}

mc_command() {
    cmd="$1"
    /usr/bin/tmux -L ${TMUX_SOCKET} send-keys -t ${TMUX_SESSION}.0 "$cmd" ENTER
    return ${?}
}

start_server() {
    if is_server_running; then
        echo "BungeeCord already running"
        return 1
    else
        echo "Starting BungeeCord in tmux session"
        /usr/bin/tmux -L ${TMUX_SOCKET} new-session -c ${MC_HOME} -s ${TMUX_SESSION} -d /usr/bin/java -Xms${MC_MIN_RAM} -Xmx${MC_MAX_RAM} ${MC_JVM_PARAMETERS} -jar ${MC_HOME}/$MC_JAR_FILE
        return ${?}
    fi
}

stop_server() {
    if ! is_server_running; then
        echo "BungeeCord is not running!"
        return 1
    else
        echo "Stopping BungeeCord"
        mc_command "end"
        if [[ ${?} -ne 0 ]]; then
            echo "Failed to send stop command to BungeeCord"
            return 1
        fi

        # Wait for server to stop
        wait=0
        while is_server_running; do
            sleep 1

            wait=$((wait+1))
            if [ ${wait} -gt 10 ]; then
                echo "Could not stop BungeeCord, timeout"
                return 1
            fi
        done
        return 0
    fi
}

restart_server() {
    if ! is_server_running; then
        echo "BungeeCord is not running!"
        return 1
    else
        if stop_server; then
            start_server
            return ${?}
        else
            echo "Failed BungeeCord restart"
            return 1
        fi
    fi
}

reload_server() {
    /usr/bin/tmux -L ${TMUX_SOCKET} send-keys -t ${TMUX_SESSION}.0 "reload" ENTER
    return ${?}
}

attach_session() {
    if ! is_server_running; then
        echo "Cannot attach to BungeeCord session, BungeeCord not running"
        return ${?}
    else
        /usr/bin/tmux -L ${TMUX_SOCKET} attach-session -t ${TMUX_SESSION}
        return 0
    fi
}

case "$1" in
    start)
        start_server
        exit ${?}
        ;;
    stop)
        stop_server
        exit ${?}
        ;;
    restart)
        restart_server
        exit ${?}
        ;;
    reload)
        reload_server
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
