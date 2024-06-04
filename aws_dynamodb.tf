resource "aws_dynamodb_table" "website_visitor_count" {
  name         = "WebsiteVisitorCount"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "WebsiteID"

  attribute {
    name = "WebsiteID"
    type = "S"
  }

  tags = {
    Name = "WebsiteVisitorCount"
  }
}