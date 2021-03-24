data "aws_kinesis_stream" "stream" {
  name = var.input_kinesis_stream_name
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
