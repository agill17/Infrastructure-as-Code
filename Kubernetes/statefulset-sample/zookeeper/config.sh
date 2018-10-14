#!/usr/bin/env bash

### to find other peers in statefulset, you have to use OtherPodName-INDEX.GoverningSVC 

CURRENT_ID=$(hostname -s | cut -d "-" -f 2)
CURRENT_ID=$((CURRENT_ID + 1 ))
GOVERNING_SVC=$(hostname -d)
HOSTNAME=$(hostname -s | cut -d "-" -f 1)
touch $ZOOKEEPER_CFG
echo "${ZOOKEEPER_DATA_DIR}/myid contents---------"
echo $CURRENT_ID > $ZOOKEEPER_DATA_DIR/myid
cat $ZOOKEEPER_DATA_DIR/myid
echo "${ZOOKEEPER_DATA_DIR}/myid contents---------"
echo ""
if [[ $ZOOKEEPER_REPLICAS -gt 1 ]]; then
  for ((i = 0; i < $ZOOKEEPER_REPLICAS; i++)); do
    echo "server.$(( i + 1))=${HOSTNAME}-${i}.${GOVERNING_SVC}:2888:3888" >> $ZOOKEEPER_CFG
  done
fi

cat << EOF >> $ZOOKEEPER_CFG 
tickTime=2000
dataDir=${DATA_DIR:-/data/zookeeper}
clientPort=2181
initLimit=5
syncLimit=2
EOF

echo "${ZOOKEEPER_CFG} contents---------"
cat $ZOOKEEPER_CFG
echo "${ZOOKEEPER_CFG} contents---------"


${ZOOKEEPER_HOME}/bin/zkServer.sh start-foreground