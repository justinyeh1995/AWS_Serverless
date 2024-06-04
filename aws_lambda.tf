data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "lambda_functions/rest-api"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "visitor_count_function" {
  filename         = data.archive_file.lambda.output_path
  function_name    = "VisitorCountFunction"
  role             = aws_iam_role.lambda_role.arn
  handler          = "rest-api/lambda_function.lambda_handler"
  runtime          = "python3.10"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.website_visitor_count.name
    }
  }
}
