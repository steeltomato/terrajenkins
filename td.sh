#!/bin/sh

# This script wraps terradocker to simplify running terraform commands in this project
# Example usage: ./tf.sh main init
# See the readme for more details
#
# Set ARTIFACTORY="<username>:<token>" in your envvars before executing

ACCT=$1 # Name of the aws account, must match a directory under env/
shift

action=$1 # Command to issue to terraform
shift

if [ ! -d "./env/${ACCT}" ]; then
    echo "Env directory for '${ACCT}' does not exist"
    exit
fi

source ./env/${ACCT}/aws_account.sh

eval $(alks sessions open -N -a "${AWS_ACCOUNT_ROLE}" -i -f -o export)

if [[ ${action} = 'init' ]]; then
    docker run -it -v $(PWD):/work \
        -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
        -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
        -e AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN \
        coxauto/terradocker init -backend-config env/$ACCT/main.tfbackend
elif [[ ${action} = 'plan' ]] || [[ ${action} = 'apply' ]]; then
    docker run -it -v $(PWD):/work \
        -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
        -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
        -e AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN \
        coxauto/terradocker $action \
            -var-file default.tfvars \
            -var-file env/$ACCT/main.tfvars \
            -var "artifactory_creds=$ARTIFACTORY" \
            $@
else
    docker run -it -v $(PWD):/work \
        -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
        -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
        -e AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN \
        coxauto/terradocker $action $@
fi
