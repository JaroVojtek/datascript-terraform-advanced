locals {
  # Required lables
  namespace   = "engineering"
  environment = "shared-large"
  stage       = "infra"


  # Organization tagging strategy labels
  tags = {
    "${local.namespace}:ops:owner"                = "devops"
    "${local.namespace}:ops:project"              = "infra"
    "${local.namespace}:ops:environment"          = local.environment
    "${local.namespace}:ops:terraform"            = "true"
    "${local.namespace}:ops:terraform-repository" = "tf-infra"
    "${local.namespace}:ops:terraform-path"       = "services/ecr"
  }

  #
  # Expected value for the `ecr_repositories` is a map of arguments and values. The map key is the name of the repository and
  # the value is another map with required keys and several optional keys:
  #
  # - image_names:
  #   (default []) List of image names, used as repository names for AWS ECR
  #
  # - use_fullname:
  #   (default: true) Set 'true' to use `namespace-stage-name` for ecr repository name, else `name`
  #
  # - image_tag_mutability:
  #   (default MUTABLE) The tag mutability setting for the repository. Must be one of: `MUTABLE` or `IMMUTABLE`
  #
  # - scan_images_on_push:
  #   (default true) Indicates whether images are scanned after being pushed to the repository (true) or not (false)
  #
  # - enable_lifecycle_policy:
  #   (default true) Set to false to prevent the module from adding any lifecycle policies to any repositories"
  #
  # - max_image_count:
  #   (default 100) How many Docker Image versions AWS ECR will store
  #
  # - protected_tags:
  #   (default []) Name of image tags prefixes that should not be destroyed. Useful if you tag images with names like `dev`, `staging`, and `prod`
  #
  # - force_delete:
  #   (default false) Whether to delete the repository even if it contains images
  #
  ecr_repositories = {
    "shared" = {
      "image_names" = [
        "sample-app",
        "sample-app-2"
      ]
      scan_images_on_push = false
    }
  }

  # Allow other accounts/roles to access the ECR repository in read only mode
  # More info at: https://registry.terraform.io/modules/cloudposse/ecr/aws/latest#usage
  principals_readonly_access = formatlist(
    "arn:aws:iam::%s:root",
    [
      data.terraform_remote_state.dev.outputs.account_id,
      data.terraform_remote_state.prod.outputs.account_id,
    ]
  )

  # Allow other accounts/roles to access the ECR repository in read-write mode
  principals_full_access = []

  # Principal account IDs of Lambdas allowed to consume ECR
  # More info at: https://aws.amazon.com/blogs/compute/introducing-cross-account-amazon-ecr-access-for-aws-lambda/
  principals_lambda = []
}
