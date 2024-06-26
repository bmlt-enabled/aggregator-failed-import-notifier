data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda.py"
  output_path = "lambda.zip"
}

resource "aws_lambda_function" "lambda" {
  filename                       = "lambda.zip"
  function_name                  = "AggregatorFailedImportNotifier"
  role                           = aws_iam_role.lambda.arn
  handler                        = "lambda.lambda_handler"
  source_code_hash               = data.archive_file.lambda.output_base64sha256
  runtime                        = "python3.11"
  memory_size                    = 128
  timeout                        = 30
  reserved_concurrent_executions = 1

  environment {
    variables = {
      SLACK_WEBHOOK = aws_ssm_parameter.slack_webhook.value
    }
  }
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.aggregator_import_state.arn
}

import {
  to = aws_ssm_parameter.slack_webhook
  id = "/aggregator/slack_webhook"
}

resource "aws_ssm_parameter" "slack_webhook" {
  name  = "/aggregator/slack_webhook"
  type  = "String"
  value = "ADDED_IN_CONSOLE_MANUALLY"
  tags  = { Name = "AFIN - SSMParam - SLACK WEBHOOK" }
  lifecycle {
    ignore_changes = [value]
  }
}
