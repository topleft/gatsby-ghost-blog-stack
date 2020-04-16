const aws = require('aws-sdk')

exports.handler = async function(event, context) {
  console.log('Starting CodeBuild ...')
  const cb = new aws.CodeBuild()

  return cb.startBuild({
    projectName: process.env.CODEBUILD_PROJECT_NAME
  }).promise()
    .then((res) => {
      console.log('Codebuild Result:')
      console.log(res)
      return {
        'isBase64Encoded': false,
        'statusCode': 200,
        'headers': {},
        'body': 'hello'
      }
    })
    .catch((e) => {
      console.log('Codebuild error:')
      console.error(e)
      return {
        'isBase64Encoded': false,
        'statusCode': 500,
        'headers': {},
        'body': e
      }
    })
}

