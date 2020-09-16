#canal-admin V1.1.4
FROM mysql:5.7.31

COPY canal_manager.sql /docker-entrypoint-initdb.d/

ENV MYSQL_DATABASE=canal_manager \
    MYSQL_USER=canal \
    MYSQL_PASSWORD=canal \
    MYSQL_ROOT_PASSWORD=root
