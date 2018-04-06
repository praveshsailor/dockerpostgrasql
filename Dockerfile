FROM centos:latest
MAINTAINER "wirter" <praveshsailor@gmail.com>

# Steps needed to use systemd enabled docker containers.
# Reference: https://hub.docker.com/_/centos/
ENV container docker
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
    systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*;

RUN yum install -y glibc-common && yum clean all
RUN yum -y install systemd; yum clean all
# Locale.  Needed for postgres.
# Centos does not have locale-gen, the equivalent command is localedef.
RUN localedef -c -f UTF-8 -i en_US en_US.UTF-8
RUN localedef -c -f UTF-8 -i ja_JP ja_JP.UTF-8
RUN localedef -c -f UTF-8 -i de_DE de_DE.UTF-8
RUN localedef -c -f UTF-8 -i af_ZA af_ZA.UTF-8
VOLUME /run /tmp
EXPOSE 22

RUN yum -y install sudo epel-release; yum clean all
RUN rpm -Uvh https://yum.postgresql.org/9.6/redhat/rhel-7-x86_64/pgdg-centos96-9.6-3.noarch.rpm
RUN yum -y install postgresql96-server postgresql96
RUN systemctl enable postgresql-9.6
RUN echo "host all  all    0.0.0.0/0  trust" >> /var/lib/pgsql/9.6/data/pg_hba.conf
RUN echo "listen_addresses='*'" >> /var/lib/pgsql/9.6/data/postgresql.conf
COPY ./postgresql96-setup /usr/pgsql-9.6/bin/postgresql96-setup

WORKDIR /var/lib/pgsql

#CMD /bin/bash /usr/pgsql-9.6/bin/postgresql96-setup initdb
RUN rm -rf /var/lib/pgsql/9.6/data/*
RUN /bin/bash /usr/pgsql-9.6/bin/postgresql96-setup initdb
EXPOSE 5432
#VOLUME  ["/var/lib/pgsql/9.6/data"]
CMD ["/usr/sbin/init"]

