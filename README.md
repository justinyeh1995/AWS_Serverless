# AWS_Serverless

## The workflow:

1. Build step. 

Package up your function code, making sure to install any needed dependencies. Your output at this stage should be a zipped-up Lambda function artifact and a config file ready to deploy your resources.

2. Deploy step. 

Run your IaC tool to deploy the resources in AWS.

3. Smoke test step. 

Run your Cypress API tests to make sure the deployed API does what you think it should.

❗️ Always check your custom IAM policy & role before deploying your resources.
