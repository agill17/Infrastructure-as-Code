#!/usr/bin/env bash

POD_INDEX=$(hostname -s | cut -d "-" -f 2)
BROKER_ID=$((POD_INDEX + 1))

cat <<EOF >> $KAFKA_CONF_FILE
broker.id=${BROKER_ID}
num.network.threads=3
num.io.threads=8
advertised.listeners=PLAINTEXT://${POD_IP}:9092
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
log.dirs=${LOG_DIR:-/var/logs/kafka}
num.partitions=1
num.recovery.threads.per.data.dir=1
log.retention.hours=${RETENTION_PERIOD:-12}
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
delete.topic.enable=true
zookeeper.connection.timeout.ms=6000
zookeeper.connect=${ZOOKEEPER}
EOF


cat $KAFKA_CONF_FILE

./bin/kafka-server-start.sh $KAFKA_CONF_FILE
