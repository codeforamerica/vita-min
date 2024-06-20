FROM alpine:3.10
MAINTAINER Anees tofarrell@codeforamerica.org

# Install packages
#RUN apk update && \
#    apk add ca-certificates wget python python-dev py-pip && \
#    update-ca-certificates && \
#    pip install --upgrade --user awscli

# Setting environment variables
ENV JMETER_HOME /opt/apache-jmeter-5.6.3
ENV JMETER_BIN	${JMETER_HOME}/bin
ENV TESTDIR /test/
ENV PATH="~/.local/bin:$PATH"


RUN apk upgrade
RUN apk update
RUN apk add --no-cache bash
RUN apk add curl
# Downloading JMETER and copying into the opt path
RUN curl -L --silent https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-5.6.3.tgz > /tmp/apache-jmeter-5.6.3.tgz
RUN tar -xzf /tmp/apache-jmeter-5.6.3.tgz -C /opt
RUN apk add --update openjdk8-jre tzdata curl unzip bash

ENV PATH $PATH:$JMETER_BIN
WORKDIR	${TESTDIR}

# Copying the JMX file and entrypoint file(this runs the test)
COPY fyst_az_5_minute_stress_test.jmx $TESTDIR
COPY entrypoint.sh $TESTDIR
COPY jmeter_test $TESTDIR
RUN mkdir -p ${TESTDIR}results

# Not working
#ENTRYPOINT ["./jmeter_test.sh -t fyst_az_5_minute_stress_test -e staging"]

# Working
#ENTRYPOINT ["ls"]

ENTRYPOINT ["./entrypoint.sh"]
