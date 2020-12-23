# Deploy a static site to AWS using Terraform Cloud

![visual](visual.png)

This repository is used by Terraform Cloud to create
CodePipeline
Github repository
CodeBuild build project
S3 bucket
ACM certificate
CloudFront distribution
Route53 record zone and record

Static site files and a Codebuild buildspec can be pushed to the output repository which delivers the site.
