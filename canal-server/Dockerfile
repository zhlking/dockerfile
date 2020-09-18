FROM openjdk:8-jre-slim

MAINTAINER zhlking (zhlking@cnklog.com)

ENV TZ="Asia/Shanghai" \
    # canal-admin访问地址    {canal.admin.manager}
    CANAL_ADMIN_ADDR=127.0.0.1:8089 \
    # 暴露端口   {canal.admin.port}
    CANAL_ADMIN_PORT=11110 \
    # 平台对接账户    {canal.admin.user}
    CANAL_ADMIN_USER=admin \
    # 平台对接密码 base64加密   {canal.admin.passwd}
    CANAL_ADMIN_PASSWD=admin \
    # 平台访问端口    ｛canal.admin.register.cluster｝
    CANAL_CLUSTER=CanalDigit

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

ARG CANAL_VERSION=1.1.4
ARG CanalUrl="https://github.com/alibaba/canal/releases/download/"
ARG Metrics_VERSION=0.18.1
ARG MetricsUrl="https://github.com/prometheus/node_exporter/releases/download/"

# 下载 Nacos
RUN set -eux; \
    ddist() { \
        local distUrl="$1"; shift; \
        local File="$1"; shift; \
        local distFile="$1"; shift; \
        local success=; \
        if wget -q -O "$File" "$distUrl$distFile" && [ -s "$File" ]; then \
            success=1; \
            break; \
        fi; \
        [ -n "$success" ]; \
    }; \
    ddist "$CanalUrl" "canal.deployer-${CANAL_VERSION}.tar.gz" "canal-${CANAL_VERSION}/canal.deployer-${CANAL_VERSION}.tar.gz"; \
    ddist "$MetricsUrl" "node_exporter-$Metrics_VERSION.linux-arm64.tar.gz" "v$Metrics_VERSION/node_exporter-$Metrics_VERSION.linux-arm64.tar.gz"; \
    mkdir -p /home/admin/canal-server; \
    tar -zxf "canal.deployer-${CANAL_VERSION}.tar.gz" -C /home/admin/canal-server; \
    tar -zxf "node_exporter-$Metrics_VERSION.linux-arm64.tar.gz" -C /home/admin/; \
    mv /home/admin/node_exporter-$Metrics_VERSION.linux-arm64 /home/admin/node_exporter; \
    rm -rf canal.deployer-${CANAL_VERSION}.tar.gz \
           node_exporter-$Metrics_VERSION.linux-arm64.tar.gz \
           /home/admin/canal-server/bin/*.bat

ADD admin/ /home/admin/canal-server/bin/

# 创建指定UID/GID的用户和需要的目录
RUN set -eux; \
    groupadd -r admin --gid=1000; \
    useradd -d /home/admin -g admin --uid=1000 admin; \
    chown -R admin: /home/admin/canal-server; \
    chmod -R 755 /home/admin/canal-server \
                 /home/admin/node_exporter

WORKDIR /home/admin

EXPOSE 11110 11111 11112 9100

CMD ["/home/admin/canal-server/bin/app.sh"]
