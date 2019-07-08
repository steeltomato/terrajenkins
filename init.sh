#!/bin/sh
set -e

ACCT=$1
shift

function tfbackend_prop {
    grep "${1}" env/${ACCT}/main.tfbackend | cut -d'=' -f2 | tr -d '"' | tr -d ' '
}

if [ ! -d "./env/${ACCT}" ]; then
    echo "Env directory for '${ACCT}' does not exist"
    exit
fi

source ./env/${ACCT}/aws_account.sh

alks sessions open -N -a "${AWS_ACCOUNT_ROLE}" -i -f -o creds

BUCKET=$(tfbackend_prop 'bucket')

if aws s3api get-bucket-location --bucket ${BUCKET} 2>&1 | grep -q 'NoSuchBucket'; then
    echo "Creating S3 bucket ${BUCKET}"
    aws s3api create-bucket --bucket ${BUCKET} --region ${AWS_REGION}
fi

./publish-image.sh $ACCT master

rm -rf ./.terraform/

echo "Init Complete"
