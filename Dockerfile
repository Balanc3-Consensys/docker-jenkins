FROM ubuntu:14.04
 
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN locale-gen en_US en_US.UTF-8
ENV LANG en_US.UTF-8
RUN echo "export PS1='\e[1;31m\]\u@\h:\w\\$\[\e[0m\] '" >> /root/.bashrc

#Runit
RUN apt-get install -y runit 
CMD export > /etc/envvars && /usr/sbin/runsvdir-start
RUN echo 'export > /etc/envvars' >> /root/.bashrc

#Utilities
RUN apt-get install -y vim less net-tools inetutils-ping wget curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common jq psmisc

#Install Oracle Java 8
RUN add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java8-installer
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

#Jenkins
RUN wget http://updates.jenkins-ci.org/download/war/1.643/jenkins.war

#Subversion
RUN apt-get install -y subversion

#Docker client only
RUN wget -O /usr/local/bin/docker https://get.docker.io/builds/Linux/x86_64/docker-latest && \
    chmod +x /usr/local/bin/docker

#Kubectl
RUN cd /usr/bin && \
    wget https://storage.googleapis.com/kubernetes-release/release/v1.1.4/bin/linux/amd64/kubectl && \
    chmod +x kubectl

RUN curl -L https://raw.githubusercontent.com/hgomez/devops-incubator/master/forge-tricks/batch-install-jenkins-plugins.sh -o batch-install-jenkins-plugins.sh && \
    chmod +x batch-install-jenkins-plugins.sh

COPY plugins.txt /
RUN mkdir -p /root/.jenkins/plugins && \
    ./batch-install-jenkins-plugins.sh --plugins plugins.txt --plugindir /root/.jenkins/plugins

#Copy Jobs
COPY jenkins/jobs/ /root/.jenkins/jobs/

#Add runit services
ADD sv /etc/service 
