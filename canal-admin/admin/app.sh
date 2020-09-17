#!/bin/bash
set -e

source /etc/profile
export JAVA_HOME=/usr/java/latest
export PATH=$JAVA_HOME/bin:$PATH
touch /tmp/start.log
chown admin: /tmp/start.log
chown -R admin: /home/admin/canal-admin
# shellcheck disable=SC2034
host=$(hostname -i)


# waitterm
#   wait TERM/INT signal.
#   see: http://veithen.github.io/2014/11/16/sigterm-propagation.html
waitterm() {
        local PID
        # any process to block
        tail -f /dev/null &
        PID="$!"
        # setup trap, could do nothing, or just kill the blocker
        # shellcheck disable=SC2064
        trap "kill -TERM ${PID}" TERM INT
        # wait for signal, ignore wait exit code
        wait "${PID}" || true
        # clear trap
        trap - TERM INT
        # wait blocker, ignore blocker exit code
        wait "${PID}" 2>/dev/null || true
}

# waittermpid "${PIDFILE}".
#   monitor process by pidfile && wait TERM/INT signal.
#   if the process disappeared, return 1, means exit with ERROR.
#   if TERM or INT signal received, return 0, means OK to exit.
waittermpid() {
        local PIDFILE PID do_run error
        PIDFILE="${1?}"
        do_run=true
        error=0
        trap "do_run=false" TERM INT
        while "${do_run}" ; do
                PID="$(cat "${PIDFILE}")"
                if ! ps -p "${PID}" >/dev/null 2>&1 ; then
                        do_run=false
                        error=1
                else
                        sleep 1
                fi
        done
        trap - TERM INT
        return "${error}"
}


function checkStart() {
    local name=$1
    local cmd=$2
    local timeout=$3
    cost=5
    while [ "$timeout" -gt 0 ]; do
        ST=$(eval "$cmd")
        if [ "$ST" == "0" ]; then
            sleep 1
            # shellcheck disable=SC2219
            let timeout=timeout-1
            # shellcheck disable=SC2219
            let cost=cost+1
        elif [ "$ST" == "" ]; then
            sleep 1
            # shellcheck disable=SC2219
            let timeout=timeout-1
            # shellcheck disable=SC2219
            let cost=cost+1
        else
            break
        fi
    done
    echo "start $name successful"
}

function start_admin() {
    echo "start admin ..."
    CANAL_SERVER_PORT=$(perl -le 'print $ENV{"server.port"}')
    if [ -z "$CANAL_SERVER_PORT" ] ; then
        CANAL_SERVER_PORT=8089
    fi
    su admin -c 'cd /home/admin/canal-admin/bin/ && sh restart.sh 1>>/tmp/start.log 2>&1'
    sleep 5
    #check start
    checkStart "canal" "nc 127.0.0.1 $CANAL_SERVER_PORT -w 1 -z | wc -l" 30
}

function stop_admin() {
    echo "stop admin"
    su admin -c 'cd /home/admin/canal-admin/bin/ && sh stop.sh 1>>/tmp/start.log 2>&1'
    echo "stop admin successful ..."
}

echo "==> START ..."

start_admin

echo "==> START SUCCESSFUL ..."

tail -f /dev/null &
# wait TERM signal
waitterm

echo "==> STOP"

stop_admin

echo "==> STOP SUCCESSFUL ..."
