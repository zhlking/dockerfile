FROM openjdk:8-jre-slim

ENV TZ="Asia/Shanghai" \
    NACOS_USER="nacos" \
    MODE="cluster" \
    PREFER_HOST_MODE="ip"\
    BASE_DIR="/home/nacos" \
    CLASSPATH=".:/home/nacos/conf:$CLASSPATH" \
    CLUSTER_CONF="/home/nacos/conf/cluster.conf" \
    FUNCTION_MODE="all" \
    NACOS_USER="nacos" \
    JVM_XMS="2g" \
    JVM_XMX="2g" \
    JVM_XMN="1g" \
    JVM_MS="128m" \
    JVM_MMS="320m" \
    NACOS_DEBUG="n" \
    TOMCAT_ACCESSLOG_ENABLED="false"

#更换源
RUN set -eux; \
    echo '  \
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
    wget; \
    rm -rf /var/lib/apt/lists/*; \
# 验证gosu命令是否能用
    gosu nobody true

ARG NACOS_VERSION=1.3.2
WORKDIR /$BASE_DIR

# 下载 Nacos
RUN set -eux; \
    ddist() { \
        local f="$1"; shift; \
        local distFile="$1"; shift; \
        local success=; \
        local distUrl=; \
        for distUrl in \
            https://github.com/alibaba/nacos/releases/download/ \
        ; do \
            if wget -q -O "$f" "$distUrl$distFile" && [ -s "$f" ]; then \
                success=1; \
                break; \
            fi; \
        done; \
        [ -n "$success" ]; \
    }; \
    ddist "nacos-server-${NACOS_VERSION}.tar.gz" "${NACOS_VERSION}/nacos-server-${NACOS_VERSION}.tar.gz"; \
    export GNUPGHOME="$(mktemp -d)"; \
    tar -zxf "nacos-server-${NACOS_VERSION}.tar.gz" -C /home; \
    rm -rf  $GNUPGHOME \
            /home/nacos-server-${NACOS_VERSION}.tar.gz \
            /home/nacos/bin/* \
            /home/nacos/conf/*.properties \
            /home/nacos/conf/*.example \
            /home/nacos/conf/nacos-mysql.sql

# 复制脚本
ADD bin/docker-startup.sh bin/docker-startup.sh
ADD conf/application.properties conf/application.properties
ADD init.d/custom.properties init.d/custom.properties

# 创建指定UID/GID的用户和需要的目录
RUN set -eux; \
    groupadd -r $NACOS_USER --gid=1000; \
    useradd -r -d $BASE_DIR -g $NACOS_USER --uid=1000 $NACOS_USER;

RUN set -eux; \
    chmod +x bin/docker-startup.sh; \
    mkdir -p logs; \
    cd logs; \
    touch start.out; \
    ln -sf /dev/stdout start.out; \
    ln -sf /dev/stderr start.out; \

EXPOSE 8848

ENTRYPOINT ["bin/docker-startup.sh"]
