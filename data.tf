data "terraform_remote_state" "vpc" {
  backend             = "s3"
  config              = {
    bucket            = var.bucket
    key               = "vpc/${var.ENV}/terraform.tfstate"
    region            = var.region
  }
}

data "aws_secretsmanager_secret" "secrets" {
  name                = "roboshop-${var.ENV}"
}

data "aws_secretsmanager_secret_version" "creds" {
  secret_id = data.aws_secretsmanager_secret.secrets.id
}
