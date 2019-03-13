FROM docker.elastic.co/kibana/kibana-oss:6.1.3
ARG LOGTRAIL_DL=https://github.com/sivasamyk/logtrail/releases/download/v0.1.25/logtrail-6.1.3-0.1.25.zip
RUN kibana-plugin install $LOGTRAIL_DL
COPY logtrail.json plugins/logtrail/logtrail.json