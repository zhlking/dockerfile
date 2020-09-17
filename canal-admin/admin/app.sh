#!/bin/bash
set -e

source /etc/profile
export JAVA_HOME=/usr/local/openjdk-8
export PATH=$JAVA_HOME/bin:$PATH
touch /tmp/start.log
chown admin: /tmp/start.log
chown -R admin: /home/admin/canal-admin/logs


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
    cd /home/admin/canal-admin/bin/ && gosu admin sh restart.sh 1>>/tmp/start.log 2>&1
    sleep 5
    #check start
#    checkStart "canal" "nc 127.0.0.1 $CANAL_SERVER_PORT -w 1 -z | wc -l" 30
}

function stop_admin() {
    echo "stop admin"
    cd /home/admin/canal-admin/bin/ && gosu admin sh stop.sh 1>>/tmp/start.log 2>&1
    echo "stop admin successful ..."
}

function conf_file() {
    cat >/home/admin/canal-admin/conf/application.yml< EOF
server:
  port: $CANAL_SERVER_PORT
spring:
  jackson:
    date-format: yyyy-MM-dd HH:mm:ss
    time-zone: GMT+8
spring.datasource:
  address: "$CANAL_MYSQL_ADDR":3306
  database: "$CANAL_MYSQL_NAME"
  username: "$CANAL_MYSQL_USER"
  password: "$CANAL_MYSQL_PASSWD"
  driver-class-name: com.mysql.jdbc.Driver
  url: jdbc:mysql://${spring.datasource.address}/${spring.datasource.database}?useUnicode=true&characterEncoding=UTF-8&useSSL=false
  hikari:
    maximum-pool-size: 30
    minimum-idle: 1
canal:
  adminUser: "$CANAL_ADMIN_USER"
  adminPasswd: "$CANAL_ADMIN_PASSWD"
    EOF
}

echo "==> 创建配置文件 ..."

conf_file

echo "==> 开始启动 ..."

start_admin

echo "==> 启动成功 ..."

tail -f /dev/null &
# wait TERM signal
waitterm

echo "==> 关闭"

stop_admin

echo "==> 已经关闭 ..."
