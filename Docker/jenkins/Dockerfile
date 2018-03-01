FROM centos:centos7

RUN yum update -y && yum install wget -y


RUN yum install java -y \
	&& wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo \
	&& rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key \
	&& yum install jenkins -y


EXPOSE 8080


RUN wget https://github.com/krallin/tini/releases/download/v0.16.1/tini_0.16.1.rpm \
	&& yum install tini_0.16.1.rpm -y


WORKDIR /lib/jenkins
RUN yum clean all


CMD ["tini", "-s", "--", "java", "-jar", "jenkins.war"]
