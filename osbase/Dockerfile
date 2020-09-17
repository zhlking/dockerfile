FROM centos:centos6.10

MAINTAINER zhlking (zhlking@cnklog.com)

env DOWNLOAD_LINK="http://download.oracle.com/otn-pub/java/jdk/8u181-b13/96a7b8442fe848ef90c96a2fad6ed6d1/jdk-8u181-linux-x64.rpm"

# install system
RUN \
    /bin/cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    groupadd -r admin && useradd -g admin admin && \
    yum install -y dstat && \
    yum install -y unzip && \
    yum install -y nc && \
    yum install -y tar && \
    yum install -y which && \
    yum install -y wget && \
    yum install -y file && \
    true

RUN \
    touch /var/lib/rpm/* && \
    wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=xxx; oraclelicense=accept-securebackup-cookie" "$DOWNLOAD_LINK" -O /tmp/jdk-8-linux-x64.rpm && \
    yum -y install /tmp/jdk-8-linux-x64.rpm && \
    /bin/rm -f /tmp/jdk-8-linux-x64.rpm && \

    echo "export JAVA_HOME=/usr/java/latest" >> /etc/profile && \
    echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/profile && \
    yum clean all && \
    true

CMD ["/bin/bash"]