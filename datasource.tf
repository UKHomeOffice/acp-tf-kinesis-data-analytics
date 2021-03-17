data "aws_kinesis_stream" "stream" {
  name = var.input_kinesis_stream_name
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_kms_key" "input_stream_key" {
  key_id = "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alias/${var.input_kinesis_stream_name}"
}
