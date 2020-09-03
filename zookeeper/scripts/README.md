#Kubernetes ZooKeeper Scripts

## Starting a ZooKeeper Server
`zookeeper-start`配置并启动一个ZooKeeper服务器。

                        
## Readiness and Liveness Checks
`zookeeper-ready`使用`ruok`四字母词执行健康检查。 它以客户端端口为参数。
如果服务器运行状况良好，它将正常退出。 如果服务器运行不正常，则会异常退出，从而导致准备就绪或活动检查失败。

## Metrics 
`zookeeper-metrics`使用`mntr`四个字母单词将度量标准打印到标准输出。 可以使用它来将Zookeeper指标与现有收集器集成在一起。