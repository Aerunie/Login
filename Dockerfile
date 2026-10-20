FROM tomcat:10.1-jdk17

# Limpiar aplicaciones por defecto de Tomcat
RUN rm -rf /usr/local/tomcat/webapps/*

# Crear las carpetas necesarias para librerías y clases compiladas
RUN mkdir -p /usr/local/tomcat/webapps/ROOT/WEB-INF/lib \
    && mkdir -p /usr/local/tomcat/webapps/ROOT/WEB-INF/classes

# Descargar el conector de MySQL
ADD https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.4.0/mysql-connector-j-8.4.0.jar /usr/local/tomcat/webapps/ROOT/WEB-INF/lib/mysql-connector-j-8.4.0.jar

# Copiar las páginas JSP y recursos web
COPY webapp/ /usr/local/tomcat/webapps/ROOT/

# Copiar el código fuente de Java al contenedor
COPY src/main/java/ /usr/src/app/

# Compilar automáticamente los archivos .java y enviarlos a WEB-INF/classes
RUN cd /usr/src/app && \
    javac -cp "/usr/local/tomcat/webapps/ROOT/WEB-INF/lib/mysql-connector-j-8.4.0.jar:/usr/local/tomcat/lib/*" \
          -d /usr/local/tomcat/webapps/ROOT/WEB-INF/classes \
          $(find . -name "*.java")

EXPOSE 8080
