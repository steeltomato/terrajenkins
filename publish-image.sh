#!/bin/sh
set -e

ACCT=$1
IMAGE=$2

if [ -z "${IMAGE}" ]; then
    echo "Usage: ./publish-image.sh <account name> <docker image>"
    exit
fi

if [ ! -d "./env/${ACCT}" ]; then
    echo "Env directory for '${ACCT}' does not exist under /env/"
    exit
fi

if [ ! -d "./docker/${IMAGE}" ]; then
    echo "Docker directory for '${IMAGE}' does not exist under /docker/"
    exit
fi

source ./env/${ACCT}/aws_account.sh

if aws ecr describe-repositories --repository-names jenkins/${IMAGE} 2>&1 | grep -q 'RepositoryNotFoundException'; then
    echo "Creating ECR repository for jenkins/${IMAGE}"
    aws ecr create-repository --repository-name jenkins/${IMAGE}
fi

$(aws ecr get-login --region us-east-1 --no-include-email)
export REPO_URL="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/jenkins/${IMAGE}"
export JENKINS_TAG=`date +%Y-%m-%d_%H-%M`

docker build -t jenkins-${IMAGE}-${JENKINS_TAG} ./docker/${IMAGE}
docker tag jenkins-${IMAGE}-${JENKINS_TAG} ${REPO_URL}:${JENKINS_TAG}
docker push ${REPO_URL}:${JENKINS_TAG}
