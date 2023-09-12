#!/bin/bash
set -e

START_TIME=$(date +%s)
APP=bull-board
GIT_SHA=$(git rev-parse --short HEAD)
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
TAG=$GIT_SHA-$GIT_BRANCH
ECR_ENDPOINT=410318292103.dkr.ecr.ap-southeast-2.amazonaws.com
KUBECONFIG=$HOME/.kube/au-prod-leadstory-config

echo "========================"
echo "Logging In..."
echo "========================"
aws ecr get-login-password --region ap-southeast-2 | docker login --username AWS --password-stdin $ECR_ENDPOINT > /dev/null 2>&1
echo "Done"

# Build Image
echo "========================"
echo "Building $APP:$TAG"
echo "========================"
if [[ `uname -m` == 'arm64' ]]; 
then
  echo Apple M1 Detected - Building For linux/amd64
  docker build --platform linux/amd64 -t $APP -f Dockerfile .
else 
  docker build . -t $APP -f Dockerfile .
fi

# Tag & Push
echo "========================"
echo "Pushing $APP:$TAG"
echo "========================"
docker tag $APP:latest $ECR_ENDPOINT/$APP:$TAG
docker tag $APP:latest $ECR_ENDPOINT/$APP:latest-$GIT_BRANCH
docker push $ECR_ENDPOINT/$APP:$TAG
docker push $ECR_ENDPOINT/$APP:latest-$GIT_BRANCH

# Deploy
echo "========================"
echo "Deploying $APP:$TAG"
echo "========================"
kubectl --kubeconfig=$KUBECONFIG patch deployment bull-board -n api --patch '{"spec": {"template": {"spec": {"containers": [{"name": "bull-board","image": "'$ECR_ENDPOINT/$APP':'$TAG'"}]}}}}'

echo "========================"
echo "Finished!"
echo "========================"
