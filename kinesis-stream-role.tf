data "aws_iam_policy_document" "kinesis_assume_role_policy_document" {
  name = "assume_role"

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["kinesisanalytics.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "kinesis_assume_role" {
  name_prefix = "kinesis-assume-role-"
  assume_role_policy = "${data.aws_iam_policy_document.kinesis_assume_role_policy_document.json}"
}


data "aws_iam_policy_document" "read_write_stream_document" {
  statement {
    sid = "ReadWriteKinesis"

    actions = [
      "kinesis:DescribeStream",
      "kinesis:GetShardIterator",
      "kinesis:GetRecords",
      "kinesis:ListShards",
      "kinesis:PutRecord"
    ]

    resources = [
      "arn:aws:kinesis:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:stream/*",
    ]
  }

}


resource "aws_iam_role_policy" "read_write_stream_policy" {
  name_prefix  = "read_write_stream_policy-"
  role   = "${aws_iam_role.assume_role.id}"
  policy = "${data.aws_iam_policy_document.read_write_stream_document.json}"
}