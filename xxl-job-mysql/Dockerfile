#xxl-job-2.2.0
FROM mysql:5.7.31

MAINTAINER zhlking (zhlking@cnklog.com)

ADD xxl-job-db.sql /docker-entrypoint-initdb.d/
#ARG XXL_JOB_VERSION=2.2.0
#RUN set -eux; \
#    apt-get update; \
#    apt-get install -y wget; \
#    rm -rf /var/lib/apt/lists/*; \
#    cd /docker-entrypoint-initdb.d/; \
#    if wget -O "tables_xxl_job.sql" "https://github.com/xuxueli/xxl-job/blob/$XXL_JOB_VERSION/doc/db/tables_xxl_job.sql" \
#    && [ -s tables_xxl_job.sql ]; then \
#        success=1; \
#        break; \
#    fi; \
#    [ -n $success ];

ENV MYSQL_ROOT_PASSWORD="root" \
    XXL_JOB_DB_NAME="xxl-job" \
    XXL_JOB_DB_USER="xxl-job" \
    XXL_JOB_DB_PASSWD="xxl-job-passwd"

RUN set -eux; \
    cd /docker-entrypoint-initdb.d/; \
    sed -i "s|XXL_JOB_DB_NAME|$XXL_JOB_DB_NAME|g" xxl-job-db.sql; \
    sed -i "s|XXL_JOB_DB_USER|$XXL_JOB_DB_USER|g" xxl-job-db.sql; \
    sed -i "s|XXL_JOB_DB_PASSWD|$XXL_JOB_DB_PASSWD|g" xxl-job-db.sql
