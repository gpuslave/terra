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

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }

    bucket = "${local.account_vars.locals.s3_backend.bucket}"
    region = "${local.account_vars.locals.s3_backend.region}"
    key    = "terragrunt/terra/${path_relative_to_include()}/tf.tfstate"

    access_key  = "${local.account_vars.locals.s3_backend.access_key}"
    secret_key  = "${local.account_vars.locals.s3_backend.secret_key}"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true # This option is required for Terraform 1.6.1 or higher.
    skip_s3_checksum            = true # This option is required to describe backend for Terraform version 1.6.3 or higher.
  }
}
EOF
}

inputs = merge(local.account_vars.locals,
local.environment_vars.locals, )