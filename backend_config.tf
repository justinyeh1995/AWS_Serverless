terraform {
  backend "s3"{
  bucket = "resume_backend_terrafor_state_bucket"
  key = "terraform.tfstate"
  region = "us-east-2"
  dynamodb_table = "terraform-state-lock"
  }
}