# The most basic, simple builder image you can use
FROM jenkins/jnlp-slave

USER root

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
    apt-get update && \
    apt-get install nodejs