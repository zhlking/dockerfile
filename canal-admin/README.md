# dockerfile

#定义变量
    # 数据库地址    {spring.datasource.address},默认端口：3306
    CANAL_MYSQL_ADDR=127.0.0.1
    
    # 数据库名    {spring.datasource.database}
    CANAL_MYSQL_NAME=canal_manager 
    
    # 数据库用户    {spring.datasource.username}
    CANAL_MYSQL_USER=canal 
    
    # 数据库用户密码    {spring.datasource.password}
    CANAL_MYSQL_PASSWD=canal 
    
    # 平台管理账户    {canal.adminUser}
    CANAL_ADMIN_USER=admin 
    
    # 平台管理密码    {canal.adminPasswd}
    CANAL_ADMIN_PASSWD=admin 
    
    # 平台访问端口    ｛server.port｝
    CANAL_SERVER_PORT=8089