data "archive_file" "tfin_lambda" {
  type        = "zip"
  source_file = "tfin_lambda.py"
  output_path = "tfin_lambda.zip"
}

resource "aws_lambda_function" "tfin_lambda" {
  filename                       = "tfin_lambda.zip"
  function_name                  = "TomatoFailedImportNotifier"
  role                           = aws_iam_role.tfin_lambda.arn
  handler                        = "tfin_lambda.lambda_handler"
  source_code_hash               = data.archive_file.tfin_lambda.output_base64sha256
  runtime                        = "python3.9"
  memory_size                    = 128
  timeout                        = 30
  reserved_concurrent_executions = 1

  environment {
    variables = {
      SLACK_WEBHOOK = var.slack_webhook
    }
  }
}

resource "aws_lambda_permission" "tfin_allow_cloudwatch" {
  statement_id  = "TfinAllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tfin_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.tomato_import_state.arn
}
