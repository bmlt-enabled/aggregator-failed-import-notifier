resource "aws_cloudwatch_event_rule" "aggregator_import_state" {
  depends_on  = [aws_lambda_function.lambda]
  name        = "aggregator-import-ecs-state-change"
  description = "Get each time a aggregator import starts/stops"

  event_pattern = jsonencode({
    source      = ["aws.ecs"]
    detail-type = ["ECS Task State Change"]
    detail = {
      clusterArn    = ["arn:aws:ecs:us-east-1:766033189774:cluster/aggregator"]
      desiredStatus = ["STOPPED"]
      group         = ["family:aggregator-import"]
    }
  })
}

resource "aws_cloudwatch_event_target" "aggregator_import_lambda" {
  target_id = "SendToLambdaAggregator"
  rule      = aws_cloudwatch_event_rule.aggregator_import_state.name
  arn       = aws_lambda_function.lambda.arn
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  retention_in_days = 7
}
