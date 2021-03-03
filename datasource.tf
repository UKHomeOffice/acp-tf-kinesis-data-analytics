data "aws_kinesis_stream" "stream" {
    name =  var.input_kinesis_stream
}

data "aws_caller_identity" "current" {}


