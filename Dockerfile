FROM ubuntu:14.04
MAINTAINER rxacevedo@fastmail.com

# This is a modified example from The Docker Book

RUN apt-get update -qq && \
    apt-get install -qqy \
    apt-transport-https \
    curl 

RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
RUN echo deb https://apt.dockerproject.org/repo ubuntu-trusty main > /etc/apt/sources.list.d/docker.list

# Honestly Maven should be part of the Docker Image in which the test is run, not Jenkins itself.
RUN apt-get update -qq && apt-get install -qqy \
            ca-certificates \
            docker-engine \
            git-core \
            iptables \
            maven \
            openjdk-7-jdk

ENV JENKINS_HOME /opt/jenkins/data
ENV JENKINS_MIRROR http://mirrors.jenkins-ci.org

RUN mkdir -p $JENKINS_HOME/plugins
RUN curl -sf -o /opt/jenkins/jenkins.war -L $JENKINS_MIRROR/war-stable/latest/jenkins.war

RUN for plugin in chucknorris greenballs scm-api git-client git ws-cleanup ;\
      do curl -sf -o $JENKINS_HOME/plugins/${plugin}.hpi \
         -L $JENKINS_MIRROR/plugins/${plugin}/latest/${plugin}.hpi; done

# ADD ./dockerjenkins.sh /usr/local/bin/dockerjenkins.sh
# RUN chmod +x /usr/local/bin/dockerjenkins.sh

# Don't care, using host socket for now
# VOLUME /var/lib/docker

EXPOSE 8080

# This is for setting up cgroups in the container
# ENTRYPOINT [ "/usr/local/bin/dockerjenkins.sh" ]

ENTRYPOINT [ "java", "-jar", "/opt/jenkins/jenkins.war" ]
