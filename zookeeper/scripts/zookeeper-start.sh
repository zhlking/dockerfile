#!/bin/bash

set -e

# Allow the container to be started with `--user`
if [[ "$1" = 'zkServer.sh' && "$(id -u)" = '0' ]]; then
    chown -R $ZOO_USER:$ZOO_USER "$ZOO_DATA_DIR" "$ZOO_DATA_LOG_DIR" "$ZOO_LOG_DIR" "$ZOO_CONF_DIR"
    exec gosu $ZOO_USER "$0" "$@"
fi

#创建目录
function create_data_dirs() {
    if [ ! -d $ZOO_CONF_DIR ]; then
        mkdir -p $LOG_DIR
        chown -R $ZOO_USER:$ZOO_USER $ZOO_CONF_DIR
    fi

    if [ ! -d $ZOO_DATA_DIR ]; then
        mkdir -p $ZOO_DATA_DIR
        chown -R $ZOO_USER:$ZOO_USER $ZOO_DATA_DIR
    fi

    if [ ! -d $ZOO_DATA_LOG_DIR ]; then
        mkdir -p $ZOO_DATA_LOG_DIR
        chown -R $ZOO_USER:USER $ZOO_DATA_LOG_DIR
    fi

    if [ ! -d $ZOO_LOG_DIR ]; then
        mkdir -p $LOG_DIR
        chown -R $ZOO_USER:$ZOO_USER $ZOO_LOG_DIR
    fi
}

# server参数配置
function print_servers() {
    for (( i=1; i<=$ZOO_SERVERS; i++ )); do
        echo "server.$i=$ZOO_NAME-$((i-1)).$ZOO_DOMAIN:$ZOO_SERVER_PORT:$ZOO_ELECTION_PORT;$ZOO_CLIENT_PORT"
    done
}

#zoo.cfg 文件配置
function create_config() {
    if [[ ! -f "$ZOO_CONF_DIR/zoo.cfg" ]]; then
        CONFIG="$ZOO_CONF_DIR/zoo.cfg"
        {
            echo "dataDir=$ZOO_DATA_DIR" 
            echo "dataLogDir=$ZOO_DATA_LOG_DIR"

            echo "tickTime=$ZOO_TICK_TIME"
            echo "initLimit=$ZOO_INIT_LIMIT"
            echo "syncLimit=$ZOO_SYNC_LIMIT"
            echo "reconfigEnabled=$ZOO_RECONFIG_ENABLED"

            echo "autopurge.snapRetainCount=$ZOO_AUTOPURGE_SNAPRETAINCOUNT"
            echo "autopurge.purgeInterval=$ZOO_AUTOPURGE_PURGEINTERVAL"
            echo "maxClientCnxns=$ZOO_MAX_CLIENT_CNXNS"
            echo "standaloneEnabled=$ZOO_STANDALONE_ENABLED"
            echo "admin.enableServer=$ZOO_ADMINSERVER_ENABLED"
        } >> "$CONFIG"

        if [[ $ZOO_SERVERS > 1 ]]; then
            print_servers >> $CONFIG
        else
            echo "server.1=localhost:$ZOO_SERVER_PORT:$ZOO_ELECTION_PORT;$ZOO_CLIENT_PORT" >> $CONFIG
        fi

        if [[ -n $ZOO_4LW_COMMANDS_WHITELIST ]]; then
            echo "4lw.commands.whitelist=$ZOO_4LW_COMMANDS_WHITELIST" >> "$CONFIG"
        fi

        for cfg_extra_entry in $ZOO_CFG_EXTRA; do
            echo "$cfg_extra_entry" >> "$CONFIG"
        done
    fi

    # 创建节点myid
    echo $MY_ID >$ZOO_DATA_DIR/myid
}

# 获取节点主机信息
ZOO_HOST=`hostname -s`
ZOO_DOMAIN=`hostname -d`

if [[ $ZOO_HOST =~ (.*)-([0-9]+)$ ]]; then
    #Pod名称前缀
    ZOO_NAME=${BASH_REMATCH[1]}
    #Pod节点ID
    ZOO_ORD=${BASH_REMATCH[2]}
else
    echo "Fialed to parse name and ordinal of Pod"
    exit 1
fi

MY_ID=$((ZOO_ORD+1))

# 生成配置文件
create_config && create_data_dirs

#查看参数配置
cat "$CONFIG"

# 启动启动程序
exec zkServer.sh start-foreground
