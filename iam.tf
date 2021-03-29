data "aws_iam_policy_document" "kinesis_assume_role_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["kinesisanalytics.amazonaws.com"]
    }
  }
}

## READ POLICY

resource "aws_iam_role" "kinesis_read_role" {
  name_prefix        = "${var.analytics_application_name}-read-"
  assume_role_policy = data.aws_iam_policy_document.kinesis_assume_role_policy_document.json
}

resource "aws_iam_role_policy" "read_stream_policy" {
  name_prefix = "${var.analytics_application_name}-read-"
  role        = aws_iam_role.kinesis_read_role.id
  policy      = data.aws_iam_policy_document.read_policy.json
}

data "aws_kms_key" "input_stream_key" {
  key_id = "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alias/${var.input_kinesis_stream_name}"
}

data "aws_iam_policy_document" "read_policy" {

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

## WRITE POLICY

resource "aws_iam_role" "kinesis_write_role" {

  for_each = local.namespaces

  name_prefix        = "${each.value}-write-"
  description        = "Kinesis Analytics role for writing to stream with name ${each.value}"
  assume_role_policy = data.aws_iam_policy_document.kinesis_assume_role_policy_document.json
}

resource "aws_iam_role_policy" "write_policy" {

  for_each = local.namespaces

  name_prefix = "${each.value}-write-"
  role        = aws_iam_role.kinesis_write_role[each.key].id
  policy      = data.aws_iam_policy_document.write_policy[each.key].json
}

data "aws_iam_policy_document" "write_policy" {

  for_each = local.namespaces

  statement {
    actions = [
      "kinesis:PutRecord",
      "kinesis:PutRecords"
    ]

    resources = [
      "arn:aws:kinesis:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:stream/${each.value}",
    ]
  }

}
