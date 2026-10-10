provider "aws" {
  region              = "ap-northeast-1"
  allowed_account_ids = ["975970278163"]

  default_tags {
    tags = {
      Project   = "beer-platform"
      ManagedBy = "terraform"
      Stack     = "bootstrap"
    }
  }
}
