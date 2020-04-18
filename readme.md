# Gatsby Ghost AWS Blog Stack

This project creates an end to end solution for a self hosted blog. After set up, a user will have a server-side rendered blog built with React, a password protected CMS with GUI for content creation, and a continuous delivery pipeline that deploys the updated content on creation and/or edit.

- Frontend - [Gatsby](https://www.gatsbyjs.org/starters/TryGhost/gatsby-starter-ghost/)
- CMS - [Ghost](https://ghost.org/docs/setup/)
- Hosting - AWS [EC2](https://aws.amazon.com/ec2/), [S3](https://aws.amazon.com/s3/) and [Cloudfront](https://aws.amazon.com/cloudfront/)
- CI/CD - AWS [Codebuild](https://aws.amazon.com/codebuild/), [API Gateway](https://aws.amazon.com/api-gateway/) and [Lambda](https://aws.amazon.com/lambda/)
- Infrastructure as Code - AWS [Cloudformation](https://aws.amazon.com/cloudformation/) and [Secrets Manager](https://aws.amazon.com/secrets-manager/)


## Architecture
<img src='./gatsby_ghost_aws_diagram.png' height=auto width=500/>


## Setup

#### .env

Create a file named  _.env_ in the root of the project and add these variables with updated values:

```
ENV=update
PROJECT_NAME=update
SSH_KEY_NAME=update
GITHUB_TOKEN=update
GITHUB_REPO_URL=update
AWS_PROFILE=update
```

#### Initial Steps

Run these commands locally to get the AWS resources deployed and configured:

1. `make create-buckets`
1. `make install-build`
1. `make package-function`
1. `make upload-function`
1. `make create-roles`
1. `make create-service`
1. `make create-build`

* If you have used codebuild with Github before, you  will likely get an error about the `SourceCredential` already being defined for type `GITHUB`. Simply remove the `SourceCredential` and the `Ref` to it in the _cloudformation/build.json_, delete the failed stack in Cloudformation via the AWS console, and locally run `make create-build` again.

### Ghost

#### Server Setup

Get the EC2 instance `Public DNS (IPv4) Address` via the aws console. It looks something like this: `ec2-55-55-55-555.compute-1.amazonaws.com`

ssh into the EC2 instance:
```
ssh -i "~/path/to/file.pem" ubuntu@<EC2 Public DNS Address>
```
> More information about accessing your EC2 instance  [here](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AccessingInstancesLinux.html).

Now follow these instructions to install  and configure Ghost: https://ghost.org/docs/install/ubuntu/

#### S3 Setup

As well, install the S3 ghost plugin and configure it: https://github.com/colinmeinke/ghost-storage-adapter-s3. You will need the AWS access keys for the Content User (found in the IAM section of  the AWS console). As well you need the Content bucket name, "${ProjectName}-content-${env}", and the cloudfront url to add as the assetHost. This  config is to be added to the configuration json file in the _/var/www/ghost/_:

```
"storage": {
  "active": "s3",
  "s3": {
    "accessKeyId": "CONTENT_USER_ACCESS_KEY_ID",
    "secretAccessKey": "CONTENT_USER_SECRET_ACCESS_KEY",
    "region": "us-east-1",
    "bucket": "CONTENT_BUCKET_NAME",
    "assetHost": "CONTENT_CDN_URL" # remember to add the https://
  }
}
```

#### Link Gatsby to Ghost Content API

Create an Integration in the Ghost admin UI and name it "Build" (you can actually name it whatever you want). While in this modal, also copy the `Content API Key`. Back in this project code add it to the file  _frontend/.ghost.json_. Push your changes up to github (and make sure they are in master).

Back in  the Ghost admin UI  in  the  "Build" integration that you just created, add a custom webhook that will invoke  the lambda via API  Gateway. It is formated like this: `{api-gateway-url}/{env}/build`. The API Gateway URL can be obtained in the AWS console.

> This webhook will trigger a build when the content changes in the Ghost CMS. This is accomplished via API Gateway backed by a Lambda that will trigger a build and deploy process via Codebuild.

### Codebuild setup

In the AWS console navigate to the recently created Codebuild project and ensure that your frontend github repo is successfully linked. To verify, navigate to  of the Codebuild project, fond `Edit` in the top right area of the screen, select `Source` from the dropdown and ensure the Source data includes this sentence, "Connection status: You are connected to GitHub using a personal access token".

Now locally, kick of a new build:
```sh
$ make start-build
```

Navigate back to the Codebuild UI and confirm that a new build is in progress a new build is in progress. If successful, your frontend will be added to the Site s3 bucket and available at the Cloudfront endpoint.

> Remember: merging to master or saving content on the Ghost admin UI will also kick off a build.

### Todo:
- add scheduled ec2 backups to cloudformation

