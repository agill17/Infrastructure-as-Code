FROM tomcat:latest
COPY Jenkinsfile/103/target/*.war webapps
EXPOSE 8080
CMD ["sh", "bin/catalina.sh", "run"]
HEALTHCHECK --interval=30s --timeout=10s --retries=2 \
	CMD curl -f localhost:8080/grants