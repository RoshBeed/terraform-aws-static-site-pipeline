terraform {
  required_version = ">=0.14"
  required_providers {
    aws = {
      source  = "aws"
      version = "~> 2.36.0"
    }
    github = {
      source = "github"
      version = "~> 4.1.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
}

provider "github" {
}

module "acm" {
  source                           = "./modules/acm"
  domain_name                      = replace(var.project_name, "-", ".")
}

module "cloudfront" {
  source                           = "./modules/cloudfront"
  domain_name                      = replace(var.project_name, "-", ".")
  s3_website_bucket_endpoint       = module.s3.s3_website_bucket_endpoint
  certificate_arn                  = module.acm.acm_arn
}

module "route53" {
  source                           = "./modules/route53"
  domain_name                      = replace(var.project_name, "-", ".")
  distribution_domain_name         = module.cloudfront.distribution_domain_name
  distribution_hosted_zone_id      = module.cloudfront.distribution_hosted_zone_id
}

module "s3" {
  source                           = "./modules/s3"
  s3_website_bucket                = replace(var.project_name, "-", ".")
}

module "github" {
  source                           = "./modules/github"
  repository_name                  = replace(var.project_name, "-", ".")
  owner_name                       = var.github_owner_name
}

module "codebuild" {
  source                           = "./modules/codebuild"
  codebuild_project_test_name      = "${var.project_name}-test"
  codebuild_project_build_name     = "${var.project_name}-build"
  codebuild_iam_role_name          = "${var.project_name}-CodeBuildIamRole"
  codebuild_iam_role_policy_name   = "${var.project_name}-CodeBuildIamRolePolicy"
  s3_website_bucket                = module.s3.s3_website_bucket
  s3_website_bucket_arn            = module.s3.s3_website_bucket_arn
  codepipeline_artifact_bucket_arn = module.codepipeline.codepipeline_artifact_bucket_arn
}

module "codepipeline" {
  source                            = "./modules/codepipeline"
  codepipeline_name                 = "${var.project_name}-CodePipeline"
  codepipeline_artifact_bucket_name = "${var.project_name}-codebuild-demo-artifact-bucket-name"
  codepipeline_role_name            = "${var.project_name}-CodePipelineIamRole"
  codepipeline_role_policy_name     = "${var.project_name}-CodePipelineIamRolePolicy"
  github_repo_name                  = module.github.github_repo_name
  github_owner                      = module.github.github_owner_name
  codebuild_test_name               = module.codebuild.codebuild_test_name
  codebuild_build_name              = module.codebuild.codebuild_build_name
}
