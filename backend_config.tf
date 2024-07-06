terraform {
  backend "s3"{
  bucket = "resume-backend-terraform-state-bucket"
  key = "terraform.tfstate"
  region = "us-east-2"
  dynamodb_table = "terraform-state-lock"
  }
}
