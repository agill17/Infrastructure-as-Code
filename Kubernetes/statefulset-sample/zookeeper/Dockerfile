FROM openjdk:8

ENV ZOOKEEPER_VERSION="3.4.13"
ENV ZOOKEEPER_DOWNLOAD_LINK="https://apache.claz.org/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/zookeeper-${ZOOKEEPER_VERSION}.tar.gz"
ENV ZOOKEEPER_DATA_DIR="/data/zookeeper"
ENV ZOOKEEPER_HOME="/opt/zookeeper-${ZOOKEEPER_VERSION}"
ENV ZOOKEEPER_REPLICAS="3"
ENV ZOOKEEPER_CFG="${ZOOKEEPER_HOME}/conf/zoo.cfg"

WORKDIR /opt

RUN wget ${ZOOKEEPER_DOWNLOAD_LINK} \
    && tar -xvf zookeeper-${ZOOKEEPER_VERSION}.tar.gz \
    && rm -rf zookeeper-${ZOOKEEPER_VERSION}.tar.gz \
    && chmod -R +x ${ZOOKEEPER_HOME}/bin

EXPOSE 2181 2888 3888
VOLUME [ "/data" ]

COPY config.sh .
RUN chmod +x config.sh
CMD ["./config.sh"]