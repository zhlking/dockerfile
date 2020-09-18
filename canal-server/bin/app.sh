#!/bin/bash
set -e

source /etc/profile
export JAVA_HOME=/usr/local/openjdk-8
export PATH=$JAVA_HOME/bin:$PATH
chown -R admin: /home/admin/canal-server

# waitterm
#   wait TERM/INT signal.
#   see: http://veithen.github.io/2014/11/16/sigterm-propagation.html
waitterm() {
        local PID
        # any process to block
        tail -f /dev/null &
        PID="$!"
        # setup trap, could do nothing, or just kill the blocker
        trap "kill -TERM ${PID}" TERM INT
        # wait for signal, ignore wait exit code
        wait "${PID}" || true
        # clear trap
        trap - TERM INT
        # wait blocker, ignore blocker exit code
        wait "${PID}" 2>/dev/null || true
}

function start_canal() {
    echo "start canal ..."
    cd /home/admin/canal-server/bin/ && gosu admin sh restart.sh 2>&1
}

function stop_canal() {
    echo "stop canal"
    cd /home/admin/canal-server/bin/ && gosu admin sh stop.sh 2>&1
    echo "stop canal successful ..."
}

function start_exporter() {
    cd /home/admin/node_exporter && gosu admin ./node_exporter 2>&1
}

function stop_exporter() {
    gosu admin killall node_exporter
}

function conf_file() {
cat << EOF > /home/admin/canal-server/conf/canal.properties
# register ip
# \${HOSTNAME} 为podname,StatefulSet类型pod名称是固定的
canal.register.ip = ${HOSTNAME}
# canal admin config
canal.admin.manager = $CANAL_ADMIN_ADDR
canal.admin.port = 11110
canal.admin.user = $CANAL_ADMIN_USER
canal.admin.passwd = $CANAL_ADMIN_PASSWD
# admin auto register
canal.admin.register.auto = true
canal.admin.register.cluster = $CANAL_CLUSTER
EOF
}
echo "==> 创建配置文件 ..."

conf_file

echo "==> START ..."

start_exporter
start_canal

echo "==> START SUCCESSFUL ..."

tail -f /dev/null &
# wait TERM signal
waitterm

echo "==> STOP"

stop_canal
start_exporter

echo "==> STOP SUCCESSFUL ..."