#!/bin/bash
set -e

export JAVA_HOME=/usr/local/openjdk-8
export PATH=$JAVA_HOME/bin:$PATH
export BASE=/home/admin/canal-admin
export LANG=en_US.UTF-8

cat << EOF > /home/admin/canal-admin/conf/application.yml
server:
  port: $CANAL_SERVER_PORT
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
  adminUser: $CANAL_ADMIN_USER
  adminPasswd: $CANAL_ADMIN_PASSWD
EOF

JAVA_OPTS="-server -Xms2048m -Xmx3072m"
JAVA_OPTS="$JAVA_OPTS -XX:+UseG1GC -XX:MaxGCPauseMillis=250 -XX:+UseGCOverheadLimit -XX:+ExplicitGCInvokesConcurrent -XX:+PrintAdaptiveSizePolicy -XX:+PrintTenuringDistribution"
JAVA_OPTS=" $JAVA_OPTS -Djava.awt.headless=true -Djava.net.preferIPv4Stack=true -Dfile.encoding=UTF-8"
CANAL_OPTS="-DappName=canal-admin"

# shellcheck disable=SC2231
for i in $BASE/lib/*;
    do CLASSPATH=$i:"$CLASSPATH";
done

CLASSPATH="$BASE/conf:$CLASSPATH";

cd $BASE
#echo CLASSPATH :"$CLASSPATH"
$JAVA "$JAVA_OPTS" "$JAVA_DEBUG_OPT" $CANAL_OPTS -classpath .:"$CLASSPATH" com.alibaba.otter.canal.admin.CanalAdminApplication 1>>/dev/null 2>&1
