module "ecr" {
  for_each = local.ecr_repositories

  source  = "cloudposse/ecr/aws"
  version = "0.35.0"

  context = module.label.context

  image_names             = lookup(each.value, "image_names", [])
  use_fullname            = lookup(each.value, "use_fullname", true)
  image_tag_mutability    = lookup(each.value, "image_tag_mutability", "MUTABLE")
  scan_images_on_push     = lookup(each.value, "scan_images_on_push", true)
  enable_lifecycle_policy = lookup(each.value, "enable_lifecycle_policy", true)
  max_image_count         = lookup(each.value, "max_image_count", 100)
  protected_tags          = lookup(each.value, "protected_tags", [])
  force_delete            = lookup(each.value, "force_delete", false)

  principals_readonly_access = local.principals_readonly_access
  principals_full_access     = local.principals_full_access
  principals_lambda          = local.principals_lambda
}
