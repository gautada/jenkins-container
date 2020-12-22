FROM alpine:3.12.1 as config-alpine

RUN apk add --no-cache tzdata

RUN cp -v /usr/share/zoneinfo/America/New_York /etc/localtime
RUN echo "America/New_York" > /etc/timezone

FROM alpine:edge as src-jenkins

RUN apk add --no-cache git maven openjdk8 yarn

# RUN git clone --branch 4.2.0 --depth 1 https://github.com/spotbugs/spotbugs.git
# WORKDIR /spotbugs
# RUN ./gradlew

# RUN git clone --branch spotbugs-maven-plugin-4.1.4 --depth 1 \
#  https://github.com/spotbugs/spotbugs-maven-plugin.git
# WORKDIR /spotbugs-maven-plugin
# RUN mvn -DskipTests=true clean install

RUN git clone --branch jenkins-2.269 --depth 1 https://github.com/jenkinsci/jenkins.git
WORKDIR /jenkins
RUN mvn -DskipTests=true clean install

CMD ["tail", "-f", "/dev/null"]
