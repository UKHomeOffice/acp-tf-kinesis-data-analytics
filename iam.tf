data "aws_iam_policy_document" "kinesis_assume_role_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["kinesisanalytics.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "kinesis_assume_role" {
  name_prefix        = "${var.analytics_application_name}-role-"
  assume_role_policy = data.aws_iam_policy_document.kinesis_assume_role_policy_document.json
}

data "aws_kms_key" "input_stream_key" {
  key_id = "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alias/${var.input_kinesis_stream_name}"
}

data "aws_iam_policy_document" "read_write_stream_document" {
  
  statement {
    actions = [
      "kms:Decrypt"
    ]

    resources = [
      data.aws_kms_key.input_stream_key.arn
    ]
  }
  
  statement {
    actions = [
      "kinesis:DescribeStream",
      "kinesis:GetShardIterator",
      "kinesis:GetRecords",
      "kinesis:ListShards",
      "kinesis:PutRecord",
      "kinesis:PutRecords"
    ]

    resources = [
      "arn:aws:kinesis:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:stream/*",
    ]
  }

}

resource "aws_iam_role_policy" "read_write_stream_policy" {
  name_prefix = "${var.analytics_application_name}-role-policy-"
  role        = aws_iam_role.kinesis_assume_role.id
  policy      = data.aws_iam_policy_document.read_write_stream_document.json
}
