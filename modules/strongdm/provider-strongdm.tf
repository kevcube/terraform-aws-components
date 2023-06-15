provider "aws" {
  alias  = "api_keys"
  region = var.ssm_region

  # Profile is deprecated in favor of terraform_role_arn. When profiles are not in use, terraform_profile_name is null.
  profile = module.iam_roles_network.terraform_profile_name

  dynamic "assume_role" {
    # module.iam_roles_network.terraform_role_arn may be null, in which case do not assume a role.
    for_each = compact([module.iam_roles_network.terraform_role_arn])
    content {
      role_arn = module.iam_roles_network.terraform_role_arn
    }
  }
}

module "iam_roles_network" {
  source  = "../account-map/modules/iam-roles"
  stage   = var.ssm_account
  context = module.this.context
}

provider "sdm" {
  api_access_key = local.enabled ? data.aws_ssm_parameter.api_access_key[0].value : null
  api_secret_key = local.enabled ? data.aws_ssm_parameter.api_secret_key[0].value : null
}