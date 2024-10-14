resource "aws_sns_topic" "dynamodb_event_notifications" {
  name = "dynamodb-event-notifications"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.dynamodb_event_notifications.arn
  protocol  = "email"
  endpoint  = "carolitagzr@gmail.com" 
}
resource "aws_cloudwatch_event_rule" "dynamodb_stream_rule" {
  name        = "dynamodb-stream-rule"
  description = "Captura eventos de la tabla DynamoDB"
   #∫ "detail-type": ["AWS API Call via CloudTrail"],
  event_pattern = <<PATTERN
{
  "source": ["aws.dynamodb"],
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventSource": ["dynamodb.amazonaws.com"]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "sns_target" {
  rule = aws_cloudwatch_event_rule.dynamodb_stream_rule.name
  arn  = aws_sns_topic.dynamodb_event_notifications.arn
}

# Crear los permisos necesarios para que EventBridge pueda publicar en SNS
resource "aws_iam_role" "eventbridge_to_sns_role" {
  name = "eventbridge-to-sns-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "eventbridge_to_sns_policy" {
  role = aws_iam_role.eventbridge_to_sns_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sns:Publish",
      "Resource": "${aws_sns_topic.dynamodb_event_notifications.arn}"
    }
  ]
}
EOF
}

