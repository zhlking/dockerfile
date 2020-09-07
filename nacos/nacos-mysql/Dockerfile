FROM mysql:5.7.31

COPY nacos-init.sql /docker-entrypoint-initdb.d/

EXPOSE 3306

ENTRYPOINT ["docker-entrypoint.sh"]
