#!/bin/sh
set -e

ACCT=$1

source ../../env/${ACCT}/aws_account.sh

alks sessions open -N -a "${AWS_ACCOUNT_ROLE}" -i -f -o creds

# Publish custom Jenkins docker image
$(aws ecr get-login --region us-east-1 --no-include-email)
export REPO_URL="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/jenkins/builder-conda"
export JENKINS_TAG=`date +%Y-%m-%d_%H-%M`

docker build -t jenkins-builder-conda .
docker tag jenkins-builder-conda ${REPO_URL}:${JENKINS_TAG}
docker push ${REPO_URL}:${JENKINS_TAG}
