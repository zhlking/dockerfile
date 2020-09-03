FROM openjdk:11-jre-slim

ENV TZ="Asia/Shanghai" \
    ZOO_USER=zookeeper \
    ZOO_SERVERS=3 \
    ZOO_CLIENT_PORT=2181 \
    ZOO_SERVER_PORT=2888 \
    ZOO_ELECTION_PORT=3888 \
    ZOO_CONF_DIR=/conf \
    ZOO_DATA_DIR=/data \
    ZOO_DATA_LOG_DIR=/datalog \
    ZOO_LOG_DIR=/logs \
    ZOO_TICK_TIME=2000 \
    ZOO_INIT_LIMIT=5 \
    ZOO_SYNC_LIMIT=2 \
    ZOO_AUTOPURGE_PURGEINTERVAL=6 \
    ZOO_AUTOPURGE_SNAPRETAINCOUNT=3 \
    ZOO_MAX_CLIENT_CNXNS=100 \
    ZOO_STANDALONE_ENABLED=false \
    ZOO_RECONFIG_ENABLED=false \
    ZOO_4LW_COMMANDS_WHITELIST=ruok,mntr \
    ZOO_ADMINSERVER_ENABLED=false


# 安装所需软件包
RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        dirmngr \
        gosu \
        gnupg \
        netcat \
        procps \
        wget; \
    rm -rf /var/lib/apt/lists/*; \
# 验证gosu命令是否能用
    gosu nobody true

ARG GPG_KEY=52A7EA3EECAE05B0A8306471790761798F6E35FC
ARG SHORT_DISTRO_NAME=zookeeper-3.5.8
ARG DISTRO_NAME=apache-zookeeper-3.5.8-bin

# Download Apache Zookeeper, verify its PGP signature, untar and clean up
RUN set -eux; \
    ddist() { \
        local f="$1"; shift; \
        local distFile="$1"; shift; \
        local success=; \
        local distUrl=; \
        for distUrl in \
            'https://www.apache.org/dyn/closer.cgi?action=download&filename=' \
            https://www-us.apache.org/dist/ \
            https://www.apache.org/dist/ \
            https://archive.apache.org/dist/ \
        ; do \
            if wget -q -O "$f" "$distUrl$distFile" && [ -s "$f" ]; then \
                success=1; \
                break; \
            fi; \
        done; \
        [ -n "$success" ]; \
    }; \
    ddist "$DISTRO_NAME.tar.gz" "zookeeper/$SHORT_DISTRO_NAME/$DISTRO_NAME.tar.gz"; \
    ddist "$DISTRO_NAME.tar.gz.asc" "zookeeper/$SHORT_DISTRO_NAME/$DISTRO_NAME.tar.gz.asc"; \
    mkdir -p "$ZOO_DATA_LOG_DIR" "$ZOO_DATA_DIR" "$ZOO_CONF_DIR" "$ZOO_LOG_DIR"; \
    export GNUPGHOME="$(mktemp -d)"; \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-key "$GPG_KEY" || \
    gpg --keyserver pgp.mit.edu --recv-keys "$GPG_KEY" || \
    gpg --keyserver keyserver.pgp.com --recv-keys "$GPG_KEY"; \
    gpg --batch --verify "$DISTRO_NAME.tar.gz.asc" "$DISTRO_NAME.tar.gz"; \
    tar -zxf "$DISTRO_NAME.tar.gz"; \
    mv "$DISTRO_NAME/conf/"* "$ZOO_CONF_DIR"; \
    rm -rf "$GNUPGHOME" "$DISTRO_NAME.tar.gz" "$DISTRO_NAME.tar.gz.asc"

# 复制脚本
COPY scripts/*.sh /

# 创建指定UID/GID的用户和需要的目录
RUN set -eux; \
    groupadd -r $ZOO_USER --gid=1000; \
    useradd -r -g $ZOO_USER --uid=1000 $ZOO_USER; \
    chown $ZOO_USER:$ZOO_USER "$ZOO_DATA_LOG_DIR" "$ZOO_DATA_DIR" "$ZOO_CONF_DIR" "$ZOO_LOG_DIR"; \
    chown -R $ZOO_USER:$ZOO_USER "/$DISTRO_NAME" /*.sh; \
    chmod +x /*.sh


WORKDIR $DISTRO_NAME
VOLUME ["$ZOO_DATA_DIR", "$ZOO_DATA_LOG_DIR", "$ZOO_LOG_DIR"]

EXPOSE 2181 2888 3888 8080

ENV PATH=$PATH:/$DISTRO_NAME/bin \
    ZOOCFGDIR=$ZOO_CONF_DIR

ENTRYPOINT ["/bin/bash", "-c", "/zookeeper-start.sh"]