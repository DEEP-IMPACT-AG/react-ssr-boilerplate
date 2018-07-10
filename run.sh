
#!/bin/bash
# Usage:        run.sh [-p|--package] [-d=|--deploy] [-u|--get-url]
# Description:
# Run an AWS SAM package, deploy or URL retrieval command.

# Defaults #
# On first run, remember to create the S3 bucket with `aws s3 mb s3://BUCKET_NAME --region eu-west-1`
BUCKET_NAME="react-ssr-lambda-test"
STACK_NAME="react-ssr-lambda"

# Parse Parameters #
for ARG in $*; do
  case $ARG in
    -p|--package)
      npm run build
      sam package --template-file template.yaml --output-template-file packaged.yaml --s3-bucket $BUCKET_NAME
      ;;
    -d|--deploy)
      sam deploy --template-file packaged.yaml --stack-name $STACK_NAME --capabilities CAPABILITY_IAM
      ;;
    -u|--get-url)
      aws cloudformation describe-stacks --stack-name $STACK_NAME --query 'Stacks[].Outputs' 
      ;;
    --delete)
      aws cloudformation delete-stack --stack-name $STACK_NAME
      ;;
    --events)
      aws cloudformation describe-stack-events --stack-name react-ssr-lambda | less
      ;;
    *)
      echo "Unknown Argument $ARG"
      echo "run.sh [-p|--package] [-d=|--deploy] [-u|--get-url]"
      ;;
  esac
done

function rundocker() {
  docker run -v /Users/sam/dev/react-ssr-boilerplate:/working -it --rm ubuntu
  apt-get update
  apt-get install npm
  apt-get install awscli
  apt-get install git
  cd /working/
  rm -rf node_modules/
  npm run setup
  npm run package-deploy
}