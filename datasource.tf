data "aws_kinesis_stream" "input_stream" {
  name = var.input_kinesis_stream_name
}

data "aws_kinesis_stream" "output_stream" {
  name = var.output_kinesis_stream_name
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
