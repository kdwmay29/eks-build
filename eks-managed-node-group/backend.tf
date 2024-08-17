terraform {
  backend "s3" {
  # Replace this with your bucket name!
  bucket = "{s3-bucket-name}"
  key = "global/s3/terraform.tfstate"
  region = "ap-northeast-2"
  # Replace this with your DynamoDB table name!
  dynamodb_table = "terraform-locks"
  encrypt = true
 }
}