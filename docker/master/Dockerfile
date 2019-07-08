# Also see: https://github.com/jenkinsci/docker
# Jenkins docker tag list: https://hub.docker.com/r/jenkins/jenkins/tags
FROM jenkins/jenkins:2.183

ENV REF_DIR=${REF:-/usr/share/jenkins/ref}
ENV PLUGINS=$REF_DIR/plugins/
ENV INIT_SCRIPTS=$REF_DIR/init.groovy.d/

RUN install-plugins.sh \
  amazon-ecs:1.20 \
  antisamy-markup-formatter:1.5 \
  aws-java-sdk:1.11.562  \
  build-user-vars-plugin:1.5 \
  command-launcher:1.3 \
  credentials:2.1.18 \
  display-url-api:2.3.1 \
  docker-traceability:1.2 \
  docker-workflow:1.18 \
  ec2:1.44 \
  embeddable-build-status:2.0.1 \
  git:3.10.0 \
  github-branch-source:2.5.3 \
  github-oauth:0.32 \
  github:1.29.4 \
  job-dsl:1.74 \
  lockable-resources:2.5 \
  matrix-auth:2.4.2 \
  matrix-project:1.14 \
  Office-365-Connector:4.9.1 \
  permissive-script-security:0.5 \
  pipeline-stage-view:2.11 \
  pipeline-utility-steps:2.3.0 \
  plain-credentials:1.5 \
  role-strategy:2.11 \
  script-security:1.60 \
  simple-theme-plugin:0.5.1 \
  slack:2.27 \
  ssh-credentials:1.17 \
  timestamper:1.9 \
  workflow-aggregator:2.6 \
  workflow-cps-global-lib:2.13 \
  workflow-cps:2.68

ADD plugins $PLUGINS

COPY scripts/init/*.groovy $INIT_SCRIPTS

ENV JAVA_OPTS "-Djenkins.install.runSetupWizard=false -Dpermissive-script-security.enabled=true -Duser.timezone=America/New_York"
ENV JENKINS_OPTS="–sessionTimeout=1440"
