FROM openjdk:8-jre-slim

MAINTAINER zhlking (zhlking@cnklog.com)

ENV TZ="Asia/Shanghai" \
    # 数据库地址    {spring.datasource.address}
    CANAL_MYSQL_ADDR=127.0.0.1:3306\
    # 数据库名    {spring.datasource.database}
    CANAL_MYSQL_NAME=canal_manager \
    # 数据库用户    {spring.datasource.username}
    CANAL_MYSQL_USER=canal \
    # 数据库用户密码    {spring.datasource.password}
    CANAL_MYSQL_PASSWD=canal \
    # 平台管理账户    {canal.adminUser}
    CANAL_ADMIN_USER=admin \
    # 平台管理密码    {canal.adminPasswd}
    CANAL_ADMIN_PASSWD=admin \
    # 平台访问端口    ｛server.port｝
    CANAL_SERVER_PORT=8089 \
    spring.datasource.address=$CANAL_MYSQL_ADDR \
    spring.datasource.database=$CANAL_MYSQL_NAME \
    spring.datasource.username=$CANAL_MYSQL_USER \
    spring.datasource.password=$CANAL_MYSQL_PASSWD \
    canal.adminUser=$CANAL_ADMIN_USER \
    canal.adminPasswd=$CANAL_ADMIN_PASSWD \
    server.port=$CANAL_SERVER_PORT


#更换源
RUN set -eux; \
    echo ' \
    deb http://mirrors.aliyun.com/debian/ stretch main non-free contrib \
    deb-src http://mirrors.aliyun.com/debian/ stretch main non-free contrib \
    deb http://mirrors.aliyun.com/debian-security stretch/updates main \
    deb-src http://mirrors.aliyun.com/debian-security stretch/updates main \
    deb http://mirrors.aliyun.com/debian/ stretch-updates main non-free contrib \
    deb-src http://mirrors.aliyun.com/debian/ stretch-updates main non-free contrib \
    deb http://mirrors.aliyun.com/debian/ stretch-backports main non-free contrib \
    deb-src http://mirrors.aliyun.com/debian/ stretch-backports main non-free contrib \
    ' > /etc/apt/sources.list

# 安装所需软件包
RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    gosu \
    file \
    wget; \
    rm -rf /var/lib/apt/lists/*; \
# 验证gosu命令是否能用
    gosu nobody true

# 创建指定UID/GID的用户和需要的目录
RUN set -eux; \
    groupadd -r admin --gid=1000; \
    useradd -d /home/admin -g admin --uid=1000 admin;

ARG CANAL_VERSION=1.1.4

# 下载 Nacos
RUN set -eux; \
    ddist() { \
        local File="$1"; shift; \
        local distFile="$1"; shift; \
        local success=; \
        local distUrl="https://github.com/alibaba/canal/releases/download/"; \
        if wget -q -O "$File" "$distUrl$distFile" && [ -s "$File" ]; then \
            success=1; \
            break; \
        fi; \
        [ -n "$success" ]; \
    }; \
    ddist "canal.admin-${CANAL_VERSION}.tar.gz" "canal-${CANAL_VERSION}/canal.admin-${CANAL_VERSION}.tar.gz"; \
    mkdir -p /home/admin/canal-admin && \
    tar -zxf "canal.admin-${CANAL_VERSION}.tar.gz" -C /home/admin/canal-admin; \
    rm -rf  canal.admin-${CANAL_VERSION}.tar.gz \
            /home/admin/canal-admin/bin/*.bat

ADD admin/ /home/admin/canal-admin/bin/
WORKDIR /home/admin

EXPOSE 8089

CMD "/bin/bash" "-c" "/home/admin/canal-admin/bin/app.sh"