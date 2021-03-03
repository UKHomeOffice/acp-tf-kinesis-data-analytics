resource "aws_kinesis_analytics_application" "analytics_application" {
  name = var.analytics_application_name
  code = "CREATE OR REPLACE STREAM \"DESTINATION_SQL_STREAM\" (index VARCHAR(32), namespace VARCHAR(32)); CREATE OR REPLACE PUMP \"STREAM_PUMP\" AS INSERT INTO \"DESTINATION_SQL_STREAM\" SELECT STREAM \"index_prefix\", \"namespace_name\" FROM \"SOURCE_SQL_STREAM_001\" WHERE \"namespace_name\" = '${var.namespace_name}';"

  inputs {

    name_prefix = "SOURCE_SQL_STREAM"

    kinesis_stream {
      resource_arn = var.input_kinesis_stream.arn
      role_arn     = "${aws_iam_role.kinesis_assume_role.arn}"
    }
  }
  schema {

    record_columns {
      for_each = var.data_columns

      mapping  = each.value.mapping
      name     = each.value.name
      sql_type = each.value.sql_type
    }

    record_format {
      mapping_parameters {
        json {
          record_row_path = "$"
        }
      }
    }
  }



  outputs {
    name = var.in_application_output_stream
    schema {
      record_format_type = "JSON"
    }

    kinesis_stream {
      resource_arn = var.output_kinesis_stream_arn
      role_arn     = "${aws_iam_role.kinesis_assume_role.arn}"
    }
  }



  tags = {
    Environment = var.environment
  }
}