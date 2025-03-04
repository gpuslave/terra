locals {
  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract the variables we need for easy access
  token     = local.account_vars.locals.yandex_provider.token
  zone      = local.account_vars.locals.yandex_provider.zone
  folder_id = local.account_vars.locals.yandex_provider.folder_id
  cloud_id  = local.account_vars.locals.yandex_provider.cloud_id

  # Automatically load region-level variables
  # region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "yandex" {
  token = "${local.token}"
  zone = "${local.zone}"
  folder_id = "${local.folder_id}"
  cloud_id = "${local.cloud_id}"
}
EOF
}

inputs = merge(local.account_vars.locals,
local.environment_vars.locals, )