# Docker Image

该镜像以openjdk基础镜像版本为：11-jre-slim
zookeeper版本：3.5.8

构建映像，以便将ZooKeeper进程指定为以非root用户身份运行。默认用户是zookeeper。AdminServer默认是关闭的。ZooKeeper软件包安装"/apache-zookeeper-$DISTRO_NAME-bin"目录中，所有配置都在/conf中，ZooKeeper数据在/data中，ZooKeeper日志在/logs中。

##配置日志路径

默认情况下，ZooKeeper将日志输出到控制台。您可以通过传递环境变量ZOO_LOG4J_PROP来将日志输入到/logs中。
如下所示：

	$ docker run --name some-zookeeper --restart always -e ZOO_LOG4J_PROP="INFO,ROLLINGFILE" zookeeper


# 配置变量
## 系统环境变量

TZ
	系统时区默认为：Asia/Shanghai

ZOO_USER
    ZooKeeper默认启动用户：zookeeper

## 基础配置

如果未提供zoo.cfg文件，则使用ZooKeeper建议的默认值。可以使用以下环境变量来覆盖它们。

ZOO_CLIENT_PORT
	clientPort：客户端连接端口，默认：2181

	接受客户端的访问请求端口。

ZOO_SERVER_PORT
    数据通信端口，默认：2888

	定义集群各节点之间的数据交互的端口。

ZOO_ELECTION_PORT
    选举端口，默认：3888

	定义集群各节点之间的选举Leader的端口。

ZOO_TICK_TIME
	tickTime：CS通信心跳时间，默认为2000

	Zookeeper 服务器之间或客户端与服务器之间维持心跳的时间间隔，也就是每个 tickTime 时间就会发送一个心跳。tickTime以毫秒为单位。

## 高级配置

ZOO_MAX_CLIENT_CNXNS
	maxClientCnxns：默认为60。ZooKeeper的

	将单个客户端（由IP地址标识）可以与ZooKeeper集成中的单个成员建立的并发连接数（在套接字级别）限制为多少。这用于防止某些类的DoS攻击，包括文件描述符耗尽。默认值为60。将其设置为0将完全消除并发连接的限制。

ZOO_AUTOPURGE_PURGEINTERVAL
	autoPurge.purgeInterval：执行清理功能的时间间隔（以小时为单位），默认为6。

	设置为正整数（1或更大）以启用自动清除。官方预设为0。

ZOO_AUTOPURGE_SNAPRETAINCOUNT
	autoPurge.snapRetainCount：保留快照和相应的事务日志的个数，默认值为3。

	当启用清理功能时，保留快照和相应的事务日志的天数。

 ZOO_4LW_COMMANDS_WHITELIST
	4lw.commands.whitelist：启用四个字母单词命令列表，默认为：ruok,mntr

	不建议是用4个字母的命令,已启用ruok,mntr，用户K8S部署做验证和收集监控信息。

## 集群配置

ZOO_SERVERS
	集群模式下启动节点数，默认为：3

	在3.5版本中集群信息（服务器编号，服务器地址，LF通信端口，选举端口）格式配置：
	server.id=<address1>:<port1>:<port2>[:role];[<client port address>:]<client port>

ZOO_INIT_LIMIT
	initLimit：LF初始通信时限，默认为5。

	集群中的follower服务器(F)与leader服务器(L)之间初始连接时能容忍的最多心跳数（tickTime的数量）。

ZOO_SYNC_LIMIT
	syncLimit：LF同步通信时限默认为2。

	集群中的follower服务器与leader服务器之间请求和应答之间能容忍的最多心跳数（tickTime的数量）。

ZOO_STANDALONE_ENABLED
	standaloneEnabled：是否使用独立模式，单独的实现堆栈，默认为false。
	
	默认情况下（为了向后兼容），standaloneEnabled设置为true。设置为false可以运行分布式模式集群。

ZOO_RECONFIG_ENABLED
	reconfigEnabled：启用或禁用动态重新配置功能，默认为：false

## AdminServer

ZOO_ADMINSERVER_ENABLED
	admin.enableServer：默认为false。
	
	如果设置为true，与他相关配置是用官方默认配置。

## 安全加固

	暂无

## 增加环境配置（慎用）

ZOO_CFG_EXTRA
	ZOO_CFG_EXTRA可以将任意配置参数添加到Zookeeper配置文件中。
	
	示例：如何在端口7070上启用Prometheus指标导出器：
	$ docker run --name some-zookeeper --restart always -e ZOO_CFG_EXTRA="metricsProvider.className=org.apache.zookeeper.metrics.prometheus.PrometheusMetricsProvider metricsProvider.httpPort=7070" zookeeper

JVMFLAGS
	可以使用-Dproperty = value形式的修改Java变量来设置Zookeeper高级配置。
	
	例如，使用Netty代替NIO（默认选项）作为服务器通信框架：
	$ docker run --name some-zookeeper --restart always -e JVMFLAGS="-Dzookeeper.serverCnxnFactory=org.apache.zookeeper.server.NettyServerCnxnFactory" zookeeper

    JVMFLAGS的另一个示例用例是将最大JWM堆大小设置为1 GB：

	$ docker run --name some-zookeeper --restart always -e JVMFLAGS="-Xmx1024m" zookeeper

## Makefile
docker目录Makefile中有三个命令。

build：在本地构建Docker映像。
push：映像推送到镜像存储仓库
all：将执行build命令。


## scripts
目录包含在Kubernetes中创建ZooKeeper集群的工具。