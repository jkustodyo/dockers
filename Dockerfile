FROM openjdk:11

MAINTAINER josecustodio@tjrj.jus.br
LABEL Pentaho='Server 9.3 com drivers postgres e oracle'


# Init ENV
ENV BISERVER_VERSION 9.3
ENV BISERVER_TAG 9.3.0.0-428
ENV PENTAHO_HOME /opt/pentaho


# Apply JAVA_HOME
ENV PENTAHO_JAVA_HOME $JAVA_HOME
ENV PENTAHO_JAVA_HOME /usr/local/openjdk-11
ENV JAVA_HOME /usr/local/openjdk-11
RUN . /etc/environment \
export JAVA_HOME


#/usr/sbin/ntpdate ntp.ubuntu.com
# Install Dependences


RUN \
mkdir /opt/pentaho; \
mkdir /opt/pentaho/scripts; \
apt-get update; \
apt-get install apt-utils zip -y; \
apt-get install net-tools wget unzip git nano -y; \
apt-get update;


#apt-get update; \
#apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*;
#RUN useradd -s /bin/bash -d /opt/pentaho pentaho; chown -R pentaho:pentaho /opt/pentaho;


RUN echo '#!/bin/bash\ntouch /opt/pentaho/scripts/logando.txt;\nexport TZ=America/Sao_Paulo;\nlogando=$(date +%Y-%m-%d__%H:%M:%S);\nfind /opt/pentaho/pentaho-server/tomcat/logs -not -name "*.gz" -type f -mtime +1 -exec gzip {} \;\nfind /opt/pentaho/pentaho-server/tomcat/logs -name "*.gz" -type f -mtime +30 -exec rm {} \;\necho $logando >> /opt/pentaho/scripts/logando.txt' > /opt/pentaho/scripts/execute.sh;



RUN apt-get update; chmod +x /opt/pentaho/scripts/execute.sh;


RUN useradd -s /bin/bash -d /opt/pentaho pentaho; chown -R pentaho:pentaho /opt/pentaho;



RUN apt-get install cron -y; \
apt-get update; \
echo '*/1 * * * * /opt/pentaho/scripts/execute.sh\n\n###' > /var/spool/cron/crontabs/root; \
service cron restart;


#/usr/sbin/ntpdate ntp.ubuntu.com;
#service cron restart;
#RUN service cron restart;


# Download Pentaho BI Server
# Disable first-time startup prompt
# Disable daemon mode for Tomcat


#C:\Users\user1\Downloads\down\projetos\TJRJ\int-sistcadpj-9.3


COPY pentaho-server-ce-9.3.0.0-428.zip /tmp


RUN /usr/bin/unzip -q /tmp/pentaho-server-ce-9.3.0.0-428.zip -d /opt/pentaho; \
rm -f /tmp/pentaho-server-ce-9.3.0.0-428.zip /opt/pentaho/pentaho-server/promptuser.sh; \
sed -i -e 's/\(exec ".*"\) start/\1 run/' /opt/pentaho/pentaho-server/tomcat/bin/startup.sh; \
chmod +x /opt/pentaho/pentaho-server/start-pentaho.sh; /opt/pentaho/scripts/execute.sh;


#ADD DB drivers
COPY ./lib/. /opt/pentaho/pentaho-server/tomcat/lib


#COPY ./scripts/. /opt/pentaho/pentaho-server/scripts


#Always non-root user
USER pentaho


WORKDIR /opt/pentaho


EXPOSE 8080 8009



#CMD [cron && "sh /opt/pentaho/pentaho-server/start-pentaho.sh"]


CMD ["sh", "/opt/pentaho/pentaho-server/start-pentaho.sh"]


#ENTRYPOINT ["sh", "-c", "/opt/pentaho/pentaho-server/scripts/run.sh"]


