resource "aws_sns_topic" "ses_email_events" {
  for_each = var.create_ses_sns_topics ? var.ses_sns_topics : {}

  name              = "${module.label.id}-${each.key}-topic"
  kms_master_key_id = module.kms_sns.key_id
}

module "kms_sns" {
  source  = "cloudposse/kms-key/aws"
  version = "0.12.1"

  attributes = concat(
    var.attributes,
    ["sns"]
  )
  context = module.label.context

  description             = "KMS key for SNS at Rest encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  policy                  = try(data.aws_iam_policy_document.sns_kms_policy.json, "")

}

resource "aws_sns_topic_subscription" "ses_email_events_to_sqs" {
  for_each  = var.create_ses_sns_topics ? { for sns_topics, attributes in var.ses_sns_topics : sns_topics => attributes if attributes.subscribe_to_sqs } : {}
  topic_arn = aws_sns_topic.ses_email_events[each.key].arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.ses_queues[each.key].arn
}
