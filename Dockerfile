FROM alpine:3.12.1 as config-alpine

RUN apk add --no-cache tzdata

RUN cp -v /usr/share/zoneinfo/America/New_York /etc/localtime
RUN echo "America/New_York" > /etc/timezone

FROM alpine:edge as src-jenkins

RUN apk add --no-cache git maven openjdk8 yarn

RUN git clone --branch spotbugs-maven-plugin-4.1.4 --depth 1 \
 https://github.com/spotbugs/spotbugs-maven-plugin.git
WORKDIR /spotbugs-maven-plugin
RUN mvn -DskipTests=true clean install

WORKDIR /

RUN git clone --branch jenkins-2.269 --depth 1 https://github.com/jenkinsci/jenkins.git
WORKDIR /jenkins
RUN mvn -DskipTests=true clean install

FROM golang:1.13.15-alpine as src-docker

RUN apk add --no-cache git \
                      bash \
                      coreutils \
                      gcc \
                      musl-dev

ENV CGO_ENABLED=0 \
    DISABLE_WARN_OUTSIDE_CONTAINER=1

RUN mkdir -p /go/src/github.com/docker \
 && cd /go/src/github.com/docker \
 && git clone --depth 1 https://github.com/docker/cli.git

WORKDIR /go/src/github.com/docker/cli

RUN ./scripts/build/binary

FROM alpine:edge

COPY --from=config-alpine /etc/localtime /etc/localtime
COPY --from=config-alpine /etc/timezone  /etc/timezone

EXPOSE 8080

RUN apk add --no-cache git openjdk8-jre

COPY --from=src-docker /go/src/github.com/docker/cli/build/docker-linux-arm64 /usr/bin/docker

RUN mkdir -p /opt/jenkins-data \
 && addgroup jenkins \
 && adduser -D -s /bin/sh -G jenkins jenkins \
 && echo 'jenkins:jenkins' | chpasswd \ 
 && rm -rvf /home/jenkins \
 && ln -svf /opt/jenkins-data /home/jenkins \
 && chown -R jenkins:jenkins /opt/jenkins-data \
 && chmod -R 750 /opt/jenkins-data

COPY --from=src-jenkins /jenkins/war/target/jenkins.war /var/lib/jenkins/jenkins.war

USER jenkins
WORKDIR /home/jenkins 

ENTRYPOINT ["java"]
CMD ["-jar", "/var/lib/jenkins/jenkins.war"]
# CMD ["tail", "-f", "/dev/null"]
