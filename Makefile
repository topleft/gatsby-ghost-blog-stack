#!make
include .env
export $(cat ./.env | xargs)
# order:
	# 1. create-buckets
	# 3. create-roles
	# 4. create-service
	# 5. create-build

create-buckets:
	aws cloudformation create-stack \
  --stack-name ${PROJECT_NAME}-buckets-${ENV} \
  --template-body file://./cloudformation/buckets.json \
  --parameters \
  ParameterKey=env,ParameterValue=${ENV} \
  ParameterKey=ProjectName,ParameterValue=${PROJECT_NAME} \
  --profile ${AWS_PROFILE}

create-roles:
	aws cloudformation create-stack \
  --stack-name ${PROJECT_NAME}-roles-${ENV} \
  --template-body file://./cloudformation/roles.json \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter \
  ParameterKey=env,ParameterValue=${ENV} \
  ParameterKey=ProjectName,ParameterValue=${PROJECT_NAME} \
  ParameterKey=BucketsStack,ParameterValue=${PROJECT_NAME}-buckets-${ENV} \
  --profile ${AWS_PROFILE}

create-service:
	aws cloudformation create-stack \
  --stack-name ${PROJECT_NAME}-service-${ENV} \
  --template-body file://./cloudformation/service.json \
  --parameter \
  ParameterKey=env,ParameterValue=${ENV} \
  ParameterKey=ProjectName,ParameterValue=${PROJECT_NAME} \
  ParameterKey=KeyName,ParameterValue=${SSH_KEY_NAME} \
  ParameterKey=RolesStack,ParameterValue=${PROJECT_NAME}-roles-${ENV} \
  --profile ${AWS_PROFILE}

create-build:
	aws cloudformation create-stack \
  --stack-name ${PROJECT_NAME}-build-${ENV} \
  --template-body file://./cloudformation/build.json \
  --parameter \
  ParameterKey=env,ParameterValue=${ENV} \
  ParameterKey=BucketsStack,ParameterValue=${PROJECT_NAME}-buckets-${ENV} \
  ParameterKey=RolesStack,ParameterValue=${PROJECT_NAME}-roles-${ENV} \
  ParameterKey=ProjectName,ParameterValue=${PROJECT_NAME} \
  ParameterKey=GithubRepoUrl,ParameterValue=${GATSBY_GITHUB_REPO_URL} \
  ParameterKey=GithubToken,ParameterValue=${GITHUB_TOKEN} \
  --profile ${AWS_PROFILE}

update-buckets:
	aws cloudformation update-stack \
  --stack-name ${PROJECT_NAME}-buckets-${ENV} \
  --template-body file://./cloudformation/buckets.json \
  --parameters \
  ParameterKey=env,ParameterValue=${ENV} \
  ParameterKey=ProjectName,ParameterValue=${PROJECT_NAME} \
  --profile ${AWS_PROFILE}

update-roles:
	aws cloudformation update-stack \
  --stack-name ${PROJECT_NAME}-roles-${ENV} \
  --template-body file://./cloudformation/roles.json \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter \
  ParameterKey=env,ParameterValue=${ENV} \
  ParameterKey=ProjectName,ParameterValue=${PROJECT_NAME} \
  ParameterKey=BucketsStack,ParameterValue=${PROJECT_NAME}-buckets-${ENV} \
  --profile ${AWS_PROFILE}

update-service:
	aws cloudformation update-stack \
  --stack-name ${PROJECT_NAME}-service-${ENV} \
  --template-body file://./cloudformation/service.json \
  --parameter \
  ParameterKey=env,ParameterValue=${ENV} \
  ParameterKey=ProjectName,ParameterValue=${PROJECT_NAME} \
  ParameterKey=KeyName,ParameterValue=${SSH_KEY_NAME} \
  ParameterKey=RolesStack,ParameterValue=${PROJECT_NAME}-roles-${ENV} \
  --profile ${AWS_PROFILE}

update-build:
	aws cloudformation update-stack \
  --stack-name ${PROJECT_NAME}-build-${ENV} \
  --template-body file://./cloudformation/build.json \
  --parameter \
  ParameterKey=env,ParameterValue=${ENV} \
  ParameterKey=BucketsStack,ParameterValue=${PROJECT_NAME}-buckets-${ENV} \
  ParameterKey=RolesStack,ParameterValue=${PROJECT_NAME}-roles-${ENV} \
  ParameterKey=ServiceStack,ParameterValue=${PROJECT_NAME}-service-${ENV} \
  ParameterKey=ProjectName,ParameterValue=${PROJECT_NAME} \
  ParameterKey=GithubRepoUrl,ParameterValue=${GATSBY_GITHUB_REPO_URL} \
	ParameterKey=GithubToken,ParameterValue=${GITHUB_TOKEN} \
  --profile ${AWS_PROFILE}

install-build:
	cd ./build-fn & CODEBUILD_PROJECT_NAME=${PROJECT_NAME}-build-${ENV} npm i

package-function:
	cd ./build-fn && rm ./function.zip && zip -q ./function.zip ./*

upload-function:
	aws s3 cp ./build-fn/function.zip s3://${PROJECT_NAME}-build-fn-${ENV}/function.zip --profile ${AWS_PROFILE}

deploy-function:
	aws lambda update-function-code --function-name ${PROJECT_NAME}-build-fn-${ENV} --s3-bucket ${PROJECT_NAME}-build-fn-${ENV} --s3-key function.zip --profile ${AWS_PROFILE}

start-build:
	aws codebuild start-build --project-name ${PROJECT_NAME}-build-${ENV} --profile ${AWS_PROFILE}
