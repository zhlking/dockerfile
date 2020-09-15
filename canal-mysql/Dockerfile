#canal-admin V1.1.4
FROM mysql:5.7.31

COPY canal_manager.sql /docker-entrypoint-initdb.d/
COPY canal-mysql-init.sh /usr/local/bin/

RUN ln -s usr/local/bin/canal-mysql-init.sh /init.sh \
    && chmod 775 /usr/local/bin/canal-mysql-init.sh \
    && chmod 755 /docker-entrypoint-initdb.d/canal_manager.sql

ENV CANAL_ADMIN_DATABASE=canal_manager \
    CANAL_ADMIN_USER=canal \
    CANAL_ADMIN_PASSWORD=canal \
    MYSQL_ROOT_PASSWORD=root

EXPOSE 3306

ENTRYPOINT docker-entrypoint.sh && canal-mysql-init.sh && mysqld
