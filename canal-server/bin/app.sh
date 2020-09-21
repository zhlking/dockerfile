#!/bin/bash
set -e

source /etc/profile
export JAVA_HOME=/usr/local/openjdk-8
export PATH=$JAVA_HOME/bin:$PATH

if [ -z "$CANAL_ADMIN_ADDR" ] ; then
  CANAL_ADMIN_ADDR="$CANAL_ADMIN_SVC_SERVICE_HOST:$CANAL_ADMIN_SVC_SERVICE_PORT"
fi

# 获取节点主机信息
CANAL_HOST=`hostname -s`
CANAL_DOMAIN=`hostname -d`

cat << EOF > /home/admin/canal-server/conf/canal.properties
# register ip
canal.register.ip = ${CANAL_HOST}.${CANAL_DOMAIN}
# canal admin config
canal.admin.manager = $CANAL_ADMIN_ADDR
canal.admin.port = 11110
canal.admin.user = $CANAL_ADMIN_USER
canal.admin.passwd = $CANAL_ADMIN_PASSWD
# admin auto register
canal.admin.register.auto = true
canal.admin.register.cluster = $CANAL_CLUSTER
EOF

sleep 5

cd /home/admin/canal-server/bin/ && gosu admin sh startup.sh 2>&1
