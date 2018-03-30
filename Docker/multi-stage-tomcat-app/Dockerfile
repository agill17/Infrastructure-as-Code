###################################################
### Maven the builder
###################################################

FROM tomcat:latest as build

ARG repo=null

RUN apt-get update  -y

WORKDIR /opt

ADD http://apache.mirrors.pair.com/maven/maven-3/3.5.3/binaries/apache-maven-3.5.3-bin.tar.gz .

RUN apt-get install git openjdk-8-jdk -y \
    && tar xzvf apache-maven-3.5.3-bin.tar.gz \
    && rm -rf apache-maven-3.5.3-bin.tar.gz \
    && mkdir /app

ENV PATH="/opt/apache-maven-3.5.3/bin:${PATH}"

WORKDIR /app

RUN git clone $repo .

RUN if [ -d target ] ; then  rm -rf target; fi \
    && mvn package 


###################################################
## Final Prod level image
###################################################


FROM tomcat:latest as final
WORKDIR /usr/local/tomcat
COPY --from=build /app/target/*.war webapps/
CMD ["sh", "bin/catalina.sh", "run"]
