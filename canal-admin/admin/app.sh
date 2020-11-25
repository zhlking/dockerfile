#!/bin/bash
set -e

source /etc/profile
export JAVA_HOME=/usr/local/openjdk-8
export PATH=$JAVA_HOME/bin:$PATH
chown -R admin: /home/admin/canal-admin
chmod -R 755 /home/admin/canal-admin

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

function start_admin() {
    echo "start admin ..."
    cd /home/admin/canal-admin/bin/ && gosu admin sh startup.sh 2>&1
}

function stop_admin() {
    echo "stop admin"
    cd /home/admin/canal-admin/bin/ && gosu admin sh stop.sh  2>&1
    echo "stop admin successful ..."
}

function conf_file() {
cat << EOF > /home/admin/canal-admin/conf/application.yml
server:
  port: $CANAL_ADMIN_PORT
spring:
  jackson:
    date-format: yyyy-MM-dd HH:mm:ss
    time-zone: GMT+8
spring.datasource:
  address: $CANAL_MYSQL_ADDR:3306
  database: $CANAL_MYSQL_NAME
  username: $CANAL_MYSQL_USER
  password: $CANAL_MYSQL_PASSWD
  driver-class-name: com.mysql.jdbc.Driver
  url: jdbc:mysql://\${spring.datasource.address}/\${spring.datasource.database}?useUnicode=true&characterEncoding=UTF-8&useSSL=false
  hikari:
    maximum-pool-size: 30
    minimum-idle: 1
canal:
  adminUser: $CANAL_SERVER_USER
  adminPasswd: $CANAL_SERVER_PASSWD
EOF
}

echo "==> 创建配置文件 ..."

conf_file

echo "==> 开始启动 ..."

start_admin

#echo "==> 启动成功 ..."
#
#tail -f /dev/null &
## wait TERM signal
#waitterm
#
#echo "==> 关闭"
#
#stop_admin
#
#echo "==> 已经关闭 ..."
