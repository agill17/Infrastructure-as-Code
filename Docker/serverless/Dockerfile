FROM alpine:latest


## RUN -- runs during image building
## CMD -- runs when initializing a container from an image

RUN apk --update add openjdk8-jre \
    && apk add wget \
    && apk add --update nodejs nodejs-npm \
    && apk -Uuv add groff less python py-pip \
    && pip install awscli


RUN npm install serverless -g \
    && mkdir /tmp/serverless

WORKDIR /tmp/serverless
COPY run_sls.sh .

RUN chmod +x run_sls.sh 

### runs a sls hello-world from a template
ENTRYPOINT [ "./run_sls.sh"]
