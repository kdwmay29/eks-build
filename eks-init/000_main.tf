#########################################################################################################
## Configure the AWS Provider
#########################################################################################################

# % export AWS_ACCESS_KEY_ID="anaccesskey"
# % export AWS_SECRET_ACCESS_KEY="asecretkey"
# % export AWS_REGION="ap-northeast-2"
# % terraform plan

provider "aws" {
  default_tags {
    tags = {
      managed_by = "terraform"
    }
  }
}