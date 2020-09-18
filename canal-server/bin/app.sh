#!/bin/bash
set -e

if [ -z "$CANAL_ADMIN_ADDR" ] ; then
  CANAL_ADMIN_ADDR="$CANAL_ADMIN_SVC_SERVICE_HOST:$CANAL_ADMIN_SVC_SERVICE_PORT"
fi

cat << EOF > /home/admin/canal-server/conf/canal.properties
# register ip
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

sh /home/admin/canal-server/bin/startup.sh