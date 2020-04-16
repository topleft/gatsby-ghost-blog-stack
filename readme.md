# Blog - Gatsby, Ghost on AWS

This project creates the infrastructure of an end to end solution for a self hosted blog. After setting this up, a user will have a serverside rendered blog built with React, a passward protected CMS with GUI for content creation, and continuous delivery pipeline that deploys the updated content on creation and/or edit.

- Frontend - [Gatsby](https://www.gatsbyjs.org/starters/TryGhost/gatsby-starter-ghost/)
- CMS - [Ghost](https://ghost.org/docs/setup/)
- Hosting - AWS [EC2](https://aws.amazon.com/ec2/), [S3](https://aws.amazon.com/s3/) and [Cloudfront](https://aws.amazon.com/cloudfront/)
- CI/CD - AWS [Codebuild](https://aws.amazon.com/codebuild/) and [Lambda](https://aws.amazon.com/lambda/)
- Infrastructure as Code -[AWS [Cloudformation](https://aws.amazon.com/cloudformation/) and [Secrets Manager](https://aws.amazon.com/secrets-manager/)

## Deploy

### .env

```
ENV=update
PROJECT_NAME=update
SSH_KEY_NAME=update
GITHUB_TOKEN=update
GATSBY_GITHUB_REPO_URL=update
AWS_PROFILE=update
```

Make sure to setup a repo and add your frontend code. I cloned this project: https://github.com/TryGhost/gatsby-starter-ghost.oject

### Steps

1. `make create-buckets`
1. `make install-build`
1. `make package-function`
1. `make upload-function`
1. `make create-roles`
1. `make create-service`
1. `make create-build`


## Ghost

## Server Setup

Get the ec2 instance Public DNS (IPv4) Address via the aws console. It looks something like this: `ec2-55-55-55-555.compute-1.amazonaws.com`

ssh into the ec2 instance:
```
ssh -i "~/path/to/file.pem" ubuntu@<EC2 Public DNS Address>
```
Now follow these instructions: https://ghost.org/docs/install/ubuntu/

## S3 Setup

As well, install the s3 plugin and configure it: https://github.com/colinmeinke/ghost-storage-adapter-s3. You will need the AWS access keys for the Content User (found in the IAM section of  the AWS console). As well you need the Content bucket name, "${ProjectName}-content-${env}", and the cloudfront url to add as the assetHost.

```
"storage": {
  "active": "s3",
  "s3": {
    "accessKeyId": "CONTENT_USER_ACCESS_KEY_ID",
    "secretAccessKey": "CONTENT_USER_SECRET_ACCESS_KEY",
    "region": "us-east-1",
    "bucket": "CONTENT_BUCKET_NAME",
    "assetHost": "CONTENT_CDN_URL"
  }
}
```

## Link Gatsby to Ghost Content API

Navigate to your ghost server in the browser and setup a new Integration by clicking the Integration button in the left side menu. Call this new  integration what ever you like  (I called mine 'Build'). Copy the `Content API Key` and back in your Gatsby repo add it to the _.ghost.json_ file. Push up your change and merge to master. (this will kick off a build). if successful, your frontend code will be added to the s3 bucket and will be available via the cloudfront url (found  in the cloudfront section of the AWS console).

Add a custom webhook to that integration and add `<api-gateway-url>/<env>/build` as the webhook url.

### Codebuild setup

In the AWS console navigate to the recently created Codebuild project and ensure that your frontend github repo is successfully linked. This information will be in the Source section of the Codebuild project.

Now locally, kick of a new build:
```
make start-build
```

Navigate back to the Codebuild UI and confirm that a new build is in progress a new build is in progress. If successful, your frontend will  be added to the Site s3 bucket and available at the cloudfront endpoint.

Remember: merging to master or saving content on the Ghost admin UI will also kick off a build.

### Todo:
- document manual steps
- add scheduled ec2 backups to cloudformation
- diagram
