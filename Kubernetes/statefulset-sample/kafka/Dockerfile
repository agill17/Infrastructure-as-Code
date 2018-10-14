FROM openjdk:8

ENV KAFKA_DOWNLOAD_LINK="http://mirrors.gigenet.com/apache/kafka/2.0.0/kafka_2.11-2.0.0.tgz"
ENV KAFKA_HOME="/opt/kafka"
ENV KAFKA_CONF_FILE="${KAFKA_HOME}/config/server.properties"
ENV POD_IP=""
ENV DEFAULT_PARTITIONS=""
ENV DEFAULT_LOG_RETENTION_HOURS=""
ENV DEFAULT_DELETE_TOPIC_POLICY=""
ENV ENABLE_AUTOCREATE_TOPICS=""
ENV ZOOKEEPER=""
RUN mkdir -p ${KAFKA_HOME} 
WORKDIR ${KAFKA_HOME}
RUN wget ${KAFKA_DOWNLOAD_LINK} -O kafka.tgz \
    && tar -xf kafka.tgz --strip 1 \
    && rm -f kafka.tgz \
    && chmod +x bin \
    && rm -f ${KAFKA_CONF_FILE}
COPY setup.sh .
RUN chmod +x setup.sh

EXPOSE 9092
VOLUME [ "/data" ]

CMD [ "./setup.sh" ]