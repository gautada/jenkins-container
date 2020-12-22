FROM alpine:3.12.1 as config-alpine

RUN apk add --no-cache tzdata

RUN cp -v /usr/share/zoneinfo/America/New_York /etc/localtime
RUN echo "America/New_York" > /etc/timezone

FROM alpine:edge as src-jenkins

RUN apk add --no-cache bash build-base git maven

RUN git clone --branch jenkins-2.269 --depth 1 https://github.com/jenkinsci/jenkins.git

WORKDIR /jenkins

CMD ["tail", "-f", "/dev/null"]
