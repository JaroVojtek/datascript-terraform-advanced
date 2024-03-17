resource "aws_sqs_queue" "ses_queues" {
  #checkov:skip=CKV_AWS_27: Ensure AWS SQS server side encryption is enabled -> SSE is enabled with SSE-SQS AWS managed key
  for_each = var.create_ses_sns_topics ? { for sns_topics, attributes in var.ses_sns_topics : sns_topics => attributes if attributes.subscribe_to_sqs } : {}

  name                    = "${module.label.id}-${each.key}-queue"
  sqs_managed_sse_enabled = true
}

resource "aws_sqs_queue_policy" "ses_queues" {
  for_each  = var.create_ses_sns_topics ? { for sns_topics, attributes in var.ses_sns_topics : sns_topics => attributes if attributes.subscribe_to_sqs } : {}
  queue_url = aws_sqs_queue.ses_queues[each.key].id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "AllowSNSsendMessage",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.ses_queues[each.key].arn}",
      "Condition": {
        "ArnLike": {
          "aws:SourceArn": "${aws_sns_topic.ses_email_events[each.key].arn}"
        }
      }
    }
  ]
}
POLICY
}
