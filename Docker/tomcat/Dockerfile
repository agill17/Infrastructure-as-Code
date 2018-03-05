FROM tomcat:7.0-alpine
RUN apk update \
	&& apk add wget
WORKDIR /usr/local/tomcat/conf/
COPY tomcat-users.xml tomcat-users.xml
RUN sed -i 's/Connector port="8080"/Connector port="8083"/g' server.xml
WORKDIR /usr/local/tomcat/webapps
VOLUME /usr/local/tomcat/webapps
RUN wget http://ec2-52-43-252-135.us-west-2.compute.amazonaws.com:8081/artifactory/addressbook/builds/lastSuccessfulBuild/archive/target/addressbook-2.0.war
