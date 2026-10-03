FROM tomcat:10.1-jdk17
RUN rm -rf /usr/local/tomcat/webapps/*
ADD https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.4.0/mysql-connector-j-8.4.0.jar /usr/local/tomcat/webapps/ROOT/WEB-INF/lib/mysql-connector-j-8.4.0.jar
COPY webapp/ /usr/local/tomcat/webapps/ROOT/
EXPOSE 8080
