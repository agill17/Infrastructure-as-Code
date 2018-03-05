FROM alpine:latest

RUN apk --update add openjdk8-jre \
	&& apk add wget \
	&& apk add unzip \
	&& wget https://bintray.com/jfrog/artifactory/download_file?file_path=jfrog-artifactory-oss-5.4.6.zip \
	&& unzip download_file?file_path=jfrog-artifactory-oss-5.4.6.zip \
	&& rm -f download_file?file_path=jfrog-artifactory-oss-5.4.6.zip

EXPOSE 8081

VOLUME artifactory_volume:/artifactory-oss-5.4.6


WORKDIR artifactory-oss-5.4.6/bin

CMD ["sh", "artifactory.sh"]
