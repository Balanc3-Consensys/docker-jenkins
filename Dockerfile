FROM ubuntu:16.04 as base

RUN apt update

# Runit
RUN apt install -y --no-install-recommends runit
CMD bash -c 'export > /etc/envvars && /usr/sbin/runsvdir-start'

# Utilities
RUN apt install -y --no-install-recommends wget curl git unzip python ssh

RUN apt install -y default-jdk

#Docker client only
RUN wget -O - https://get.docker.com/builds/Linux/x86_64/docker-latest.tgz | tar zx -C /usr/local/bin --strip-components=1 docker/docker

# Docker Compose
RUN curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

#Kubectl
RUN cd /usr/bin && \
    wget https://storage.googleapis.com/kubernetes-release/release/v1.10.1/bin/linux/amd64/kubectl && \
    chmod +x kubectl

#Ansible
RUN apt install -y libssl-dev libffi-dev python-dev python-pip
RUN pip install --upgrade setuptools
RUN pip install httplib2
RUN pip install ansible
RUN pip install yamlreader

#Jenkins
RUN wget http://updates.jenkins-ci.org/download/war/2.155/jenkins.war

#Trust Github, this is needed for SCM Configuration Plugin
RUN mkdir -p /root/.ssh && \
    ssh-keyscan github.com >> ~/.ssh/known_hosts

# Add runit services
COPY sv /etc/service 
ARG BUILD_INFO
LABEL BUILD_INFO=$BUILD_INFO
