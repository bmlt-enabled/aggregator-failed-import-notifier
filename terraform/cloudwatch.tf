resource "aws_cloudwatch_event_rule" "tomato_import_state" {
  depends_on  = [aws_lambda_function.tfin_lambda]
  name        = "tomato-import-ecs-state-change"
  description = "Get each time a tomato import starts/stops"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.ecs"
  ],
  "detail-type": [
    "ECS Task State Change"
  ],
  "detail": {
    "clusterArn": [
      "${var.tomato_cluster}"
    ]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "tomato_import_lambda" {
  target_id = "SendToLambdaTomato"
  rule      = aws_cloudwatch_event_rule.tomato_import_state.name
  arn       = aws_lambda_function.tfin_lambda.arn
}

resource "aws_cloudwatch_log_group" "tfin_lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.tfin_lambda.function_name}"
  retention_in_days = 7
}
