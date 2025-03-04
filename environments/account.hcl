locals {
  # Basic Yandex Cloud credentials
  yandex_provider = {
    token     = get_env("YC_TOKEN")
    zone      = get_env("YC_ZONE", "ru-central1-d")
    folder_id = get_env("YC_FOLDER_ID")
    cloud_id  = get_env("YC_CLOUD_ID")
  }

  # S3 backend credentials
  s3_backend = {
    access_key = get_env("ACCESS_KEY")
    secret_key = get_env("SECRET_KEY")
    bucket     = "my-new-bucket-gpuslave"
    region     = "ru-central1"
  }
}

# Remote state configuration
# remote_state {
#   backend = "s3"
#   config = {
#     endpoint    = "https://storage.yandexcloud.net"
#     bucket      = local.s3_backend.bucket
#     region      = local.s3_backend.region
#     key         = "${path_relative_to_include()}/terraform.tfstate"
#     access_key  = local.s3_backend.access_key
#     secret_key  = local.s3_backend.secret_key

#     skip_region_validation      = true
#     skip_credentials_validation = true
#     skip_requesting_account_id  = true
#     skip_s3_checksum            = true
#   }
#   generate = {
#     path      = "backend.tf"
#     if_exists = "overwrite_terragrunt"
#   }
# }

remote_state {
  backend = "s3"
  config = {
    endpoint = "https://storage.yandexcloud.net"
    encrypt        = false
    bucket         = local.s3_backend.bucket 
    key            = "terragrunt/terra/${path_relative_to_include()}/tf.tfstate"
    region         = local.s3_backend.region
    access_key  = local.s3_backend.access_key
    secret_key  = local.s3_backend.secret_key

    skip_metadata_api_check     = true
    skip_credentials_validation    = true
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}