#canal-admin V1.1.4
FROM mysql:5.7.31

COPY canal_manager.sql /docker-entrypoint-initdb.d/
COPY canal-mysql-init.sh /

ENV CANAL_ADMIN_DATABASE=canal_manager \
    CANAL_ADMIN_USER=canal \
    CANAL_ADMIN_PASSWORD=canal \
    MYSQL_ROOT_PASSWORD=root

EXPOSE 3306

ENTRYPOINT ["/bin/bash", "-c", "/entrypoint.sh && /canal-mysql-init.sh && mysqld"]
