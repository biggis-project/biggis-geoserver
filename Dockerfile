FROM biggis/tomcat:8.5.16

MAINTAINER wipatrick

ARG GEOSERVER_VERSION=2.10.4
ARG GEOMESA_VERSION=1.3.2
ARG HADOOP_VERSION=2.7.1
ARG ACCUMULO_VERSION=1.7.2
ARG THRIFT_VERSION=0.9.1
ARG ZOOKEEPER_VERSION=3.4.9

ARG BUILD_DATE
ARG VCS_REF

LABEL eu.biggis-project.build-date=$BUILD_DATE \
      eu.biggis-project.license="MIT" \
      eu.biggis-project.name="BigGIS" \
      eu.biggis-project.url="http://biggis-project.eu/" \
      eu.biggis-project.vcs-ref=$VCS_REF \
      eu.biggis-project.vcs-type="Git" \
      eu.biggis-project.vcs-url="https://github.com/biggis-project/biggis-geoserver" \
      eu.biggis-project.environment="dev" \
      eu.biggis-project.version=$GEOSERVER_VERSION

ENV CATALINA_OPTS "-Xmx8g -Duser.timezone=Europe/Berlin -server -Djava.awt.headless=true"
ENV GEOSERVER_HOME /opt/tomcat/webapps/geoserver/WEB-INF/lib

ADD geomesa-accumulo-dist_2.11-${GEOMESA_VERSION}-bin.tar.gz /opt

RUN set -x && \
    apk --update add curl openssl tar wget && \
    # Install GeoServer
    curl -sS -L -o /tmp/geoserver-war.zip \
          http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/geoserver-${GEOSERVER_VERSION}-war.zip \
    && \
    mkdir -p /opt/tomcat/webapps/geoserver && \
    unzip /tmp/geoserver-war.zip geoserver.war -d /tmp && \
    unzip /tmp/geoserver.war -d /opt/tomcat/webapps/geoserver && \
    rm -rf /tmp/geoserver-war.zip /tmp/geoserver.war /opt/tomcat/webapps/geoserver/META-INF \
    && \
    # Install WPS plugin
    curl -sS -L -o /tmp/geoserver-wps.zip \
          http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/extensions/geoserver-${GEOSERVER_VERSION}-wps-plugin.zip \
    && \
    unzip /tmp/geoserver-wps.zip -d ${GEOSERVER_HOME} && \
    rm -rf /tmp/geoserver-wps.zip \
    && \
    ln -s /opt/geomesa-accumulo_2.11-${GEOMESA_VERSION} /opt/geomesa
    #rm -rf /var/cache/apk/*

# # Install GeoMesa Accumulo DataStore
# RUN set -x \
#     && cd ${GEOSERVER_HOME} \
#     && tar zxvf /opt/geomesa/dist/gs-plugins/geomesa-accumulo-gs-plugin_2.11-${GEOMESA_VERSION}-install.tar.gz
#
# # Install GeoMesa Accumulo BlobStore
# RUN set -x \
#    && cd ${GEOSERVER_HOME} \
#    && tar zxvf /opt/geomesa/dist/gs-plugins/geomesa-blobstore-gs-plugin_2.11-${GEOMESA_VERSION}-install.tar.gz
#
# # Install GeoMesa Stream Store
# RUN set -x \
#     && cd ${GEOSERVER_HOME} \
#     && tar zxvf /opt/geomesa/dist/gs-plugins/geomesa-stream-gs-plugin_2.11-${GEOMESA_VERSION}-install.tar.gz
#
# # Install GeoMesa GeoJson Support
# RUN set -x \
#     && cd ${GEOSERVER_HOME} \
#     && tar zxvf /opt/geomesa/dist/gs-plugins/geomesa-geojson-gs-plugin_2.11-${GEOMESA_VERSION}-install.tar.gz
# 
# # Install GeoMesa Process Jar
# RUN set -x \
#     && cd ${GEOSERVER_HOME} \
#     && cp /opt/geomesa/dist/gs-plugins/geomesa-process-wps_2.11-${GEOMESA_VERSION}.jar .
#
# # Install Hadoop and Accumulo specific jars
# RUN set -x \
#     /opt/geomesa/bin/install-hadoop-accumulo.sh ${GEOSERVER_HOME} -a ${ACCUMULO_VERSION} -h ${HADOOP_VERSION} -t ${THRIFT_VERSION} -z ${ZOOKEEPER_VERSION}

RUN set -x \
  && chown root /opt/tomcat/webapps/geoserver/WEB-INF/lib/* \
  && chgrp root /opt/tomcat/webapps/geoserver/WEB-INF/lib/*

VOLUME ["/opt/tomcat/webapps/geoserver/data"]

CMD ["/opt/tomcat/startup.sh"]
