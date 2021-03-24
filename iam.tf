data "aws_iam_policy_document" "kinesis_assume_role_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["kinesisanalytics.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "kinesis_assume_read_role" {
  name_prefix        = "${var.analytics_application_name}-read-role-"
  assume_role_policy = data.aws_iam_policy_document.kinesis_assume_role_policy_document.json
}

data "aws_kms_key" "input_stream_key" {
  key_id = "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alias/${var.input_kinesis_stream_name}"
}

data "aws_kms_key" "output_stream_key" {
  key_id = "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alias/${var.output_kinesis_stream_name}"
}

data "aws_iam_policy_document" "read_stream_document" {
  
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
      "kinesis:ListShards"
    ]

    resources = [
      "arn:aws:kinesis:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:stream/${var.input_kinesis_stream_name}",
    ]
  }

}

resource "aws_iam_role_policy" "read_stream_policy" {
  name_prefix = "${var.analytics_application_name}-read-role-policy-"
  role        = aws_iam_role.kinesis_assume_role.id
  policy      = data.aws_iam_policy_document.read_stream_document.json
}

# WRITE

data "aws_iam_policy_document" "write_stream_document" {
  
  statement {
    actions = [
      "kms:Encrypt"
    ]

    resources = [
      data.aws_kms_key.output_stream_key.arn
    ]
  }
  
  statement {
    actions = [
      "kinesis:PutRecord",
      "kinesis:PutRecords"
    ]

    resources = [
      "arn:aws:kinesis:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:stream/${var.output_kinesis_stream_name}",
    ]
  }

}

resource "aws_iam_role_policy" "write_stream_policy" {
  name_prefix = "${var.analytics_application_name}-write-role-policy-"
  role        = aws_iam_role.kinesis_assume_role.id
  policy      = data.aws_iam_policy_document.write_stream_document.json
}