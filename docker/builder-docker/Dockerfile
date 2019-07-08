# Jenkins builder with docker installed, must mount /var/run/docker.sock from the host to use this
# In ECS, add the Volume at the Task level then a mount at the Container level
# This will not work with Fargate because there's no way to access docker.sock
FROM jenkins/jnlp-slave

# ARG DOCKER_VERSION=18.09.6~ce-0~debian
ARG DC_VERSION=1.24.0

USER root

RUN apt-get update && \
    apt-get install -qq -y --no-install-recommends \
      apt-transport-https \
      ca-certificates \
      curl \
      gnupg2 \
      software-properties-common && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    apt-key fingerprint 0EBFCD88 && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian stretch stable" && \
    apt-get update && \
    apt-get install -qq -y --no-install-recommends docker-ce docker-ce-cli containerd.io && \
    curl -L https://github.com/docker/compose/releases/download/${DC_VERSION}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    docker-compose version
