#!/bin/bash
set -e

source /etc/profile
export JAVA_HOME=/usr/local/openjdk-8
export PATH=$JAVA_HOME/bin:$PATH


# 获取节点主机信息
CANAL_HOST=`hostname -s`

function server_conf_file() {
cat << EOF > /home/admin/canal-server/conf/canal.properties
# register ip
canal.register.ip = $CANAL_HOST
# canal admin config
canal.admin.manager = $CANAL_ADMIN_ADDR:$CANAL_ADMIN_PORT
canal.admin.port = 11110
canal.admin.user = $CANAL_SERVER_USER
canal.admin.passwd = $CANAL_SERVER_PASSWD
# admin auto register
canal.admin.register.auto = true
canal.admin.register.cluster = $CANAL_CLUSTER
EOF
}

server_conf_file

sleep 5

cd /home/admin/canal-server/bin/ && gosu admin ./startup.sh 2>&1
