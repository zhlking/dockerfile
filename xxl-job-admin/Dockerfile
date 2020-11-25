#xxl-job-2.2.0
FROM openjdk:8-jre-slim

MAINTAINER zhlking (zhlking@cnklog.com)

RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    gosu \
    rm -rf /var/lib/apt/lists/*; \
# 验证gosu命令是否能用
    gosu nobody true

ENV TZ="Asia/Shanghai" \
    # xxl-job地址
    XXL_JOB_DB_HOST="127.0.0.1" \
    # xxl-job库名
    XXL_JOB_DB_NAME="xxl-job" \
    # xxl-job用户名
    XXL_JOB_DB_USER="xxl-job" \
    # xxl-job密码
    XXL_JOB_DB_PASSWD="xxl-job-passwd" \
    # 其他
    PARAMS=""

ADD target/xxl-job-admin-*.jar /app.jar

EXPOSE 8080

ENTRYPOINT ["sh","-c","java -jar $JAVA_OPTS /app.jar $PARAMS"]