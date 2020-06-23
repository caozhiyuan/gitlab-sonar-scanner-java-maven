FROM openjdk:8-jdk-alpine

RUN echo "http://mirrors.ustc.edu.cn/alpine/v3.4/main/" > /etc/apk/repositories
RUN echo "http://mirrors.ustc.edu.cn/alpine/v3.4/community" >> /etc/apk/repositories
RUN echo "http://mirrors.ustc.edu.cn/alpine/edge/testing" >> /etc/apk/repositories
RUN apk add curl jq procps unzip --allow-untrusted

ENV MAVEN_VERSION=3.5.3
ENV SONAR_SCANNER_VERSION=3.2.0.1227

# apache maven
RUN wget http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.zip && \
    unzip apache-maven-$MAVEN_VERSION-bin.zip && \
    rm -rf apache-maven-$MAVEN_VERSION-bin.zip && \
    mv apache-maven-$MAVEN_VERSION /usr/lib/mvn
    
# sonar-scanner
RUN wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux.zip && \
    unzip sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux.zip && \
    rm -rf sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux.zip && \
    mv sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux /usr/lib/sonar-scanner

# sonar-scanner-ext
COPY sonar-scanner-ext.sh /usr/lib
RUN ln -s /usr/lib/sonar-scanner-ext.sh /bin/sonar-scanner-ext

# update $PATH
ENV PATH="/usr/lib/mvn/bin:${PATH}"
ENV PATH="/usr/lib/sonar-scanner/bin:${PATH}"

