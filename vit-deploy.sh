#!/bin/sh
echo "-----1"
set -e
echo "-----2"
ecsCluster="myaws-cluster"
ecsService="myaws-service"
ecsTaskDefinition="vietlavel-task-def"
composedTaskDefinition="taskDefinition.json"
tmpTaskDefResult="tmp_taskDefResult.json"
templateTaskDefinition="vit-task-def-template.json"
returnedServiceUpdate="serviceUpdate.json"
returnedServiceQuery="serviceQuery.json"
returnedDeployment="primaryDeployment.json"
echo "-----3"
# For local testing only:
# lát xóa nha
# alias aws='docker run --rm -it -v ~/.aws:/root/.aws -v $(pwd):/aws amazon/aws-cli:2.0.6'
echo "-----4"
# export AWS_ECR_ACCOUNT_URL=512693189372.dkr.ecr.ap-northeast-1.amazonaws.com
# export CIRCLE_PROJECT_REPONAME=myaws
# export APP_VERSION=djhklfsjlsakjflkasskdfjl-master
echo "-----5"
# Composing task-definition json
# export APP_VERSION=${CIRCLE_SHA1}-${CIRCLE_BRANCH}
envsubst '${AWS_ECR_ACCOUNT_URL} ${CIRCLE_PROJECT_REPONAME} ${APP_VERSION}' < $templateTaskDefinition > $composedTaskDefinition
echo "-----6"
# Update ecs task-definition from json
echo "aws ecs register-task-definition --cli-input-json file://$composedTaskDefinition"
export revision=$(aws ecs register-task-definition --cli-input-json file://$composedTaskDefinition | jq -r .taskDefinition.revision)
echo "-----7"
# Update ecs service to apply task-definition
echo "aws ecs update-service --cluster $ecsCluster --service $ecsService --task-definition $ecsTaskDefinition:$revision > $returnedServiceUpdate"
aws ecs update-service --cluster $ecsCluster --service $ecsService --task-definition $ecsTaskDefinition:$revision > $returnedServiceUpdate
echo "-----8"
cat $returnedServiceUpdate | jq -r '.service.deployments[]|select(.status == "PRIMARY")' > $returnedDeployment
echo "-----9"
export desiredCount=$(cat $returnedDeployment | jq -r '.desiredCount')
export runningCount=$(cat $returnedDeployment | jq -r '.runningCount')
echo "-----10"
# while $desiredCount -ne $runningCount
echo "================== [WAITING FOR ECS DEPLOYMENT ...] "
while [ $desiredCount -ne $runningCount ]
  do
    sleep 5
    echo "================== Waiting for deployments ... "
    echo "-- desiredCount = $desiredCount "
    echo "-- runningCount = $runningCount "
    cat $returnedDeployment
    aws ecs describe-services --cluster $ecsCluster --services $ecsService > $returnedServiceQuery
    cat $returnedServiceQuery | jq -r '.services[].deployments[]|select(.status == "PRIMARY")' > $returnedDeployment
    export runningCount=$(cat $returnedDeployment | jq -r '.runningCount')
  done
