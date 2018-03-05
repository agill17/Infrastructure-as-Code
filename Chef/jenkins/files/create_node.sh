#!/bin/bash

JENKINS_URL=$1
NODE_IP_NAME=$2
NODE_SLAVE_HOME='/home/ubuntu'
EXECUTORS=1
SSH_PORT=22
CRED_ID=$3
LABELS=test_node
USERID=${USER}

#### PRE_REQ: Auto-ssh must be enabled from jenkins master to node

## Pass in at the end of the command
## if required: --username "admin" --password "admin"


### Set node conf
cat <<EOF | java -jar /var/jenkins/jenkins-cli.jar -s $1 create-node $2 --username "admin" --password "admin"
<slave>
  <name>${NODE_IP_NAME}</name>
  <description></description>
  <remoteFS>${NODE_SLAVE_HOME}</remoteFS>
  <numExecutors>${EXECUTORS}</numExecutors>
  <mode>NORMAL</mode>
  <retentionStrategy class="hudson.slaves.RetentionStrategy$Always"/>
  <launcher class="hudson.plugins.sshslaves.SSHLauncher" plugin="ssh-slaves@1.13">
    <host>${NODE_IP_NAME}</host>
    <port>${SSH_PORT}</port>
    <credentialsId>${CRED_ID}</credentialsId>
    <maxNumRetries>0</maxNumRetries>
    <retryWaitTime>0</retryWaitTime>
    <sshHostKeyVerificationStrategy class="hudson.plugins.sshslaves.verifiers.NonVerifyingKeyVerificationStrategy"/>
  </launcher>

  <label>${LABELS}</label>
  <nodeProperties/>
  <userId>${USERID}</userId>
</slave>
EOF

### Connect that node
java -jar /var/jenkins/jenkins-cli.jar -s $1 connect-node $2 --username "admin" --password "admin"
