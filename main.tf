resource "aws_kinesis_analytics_application" "analytics_application" {
  name = var.analytics_application_name

  code = <<EOF
CREATE OR REPLACE STREAM "DESTINATION_SQL_STREAM" (index VARCHAR(32), namespace VARCHAR(32)); 
CREATE OR REPLACE PUMP "STREAM_PUMP" AS INSERT INTO "DESTINATION_SQL_STREAM"
SELECT STREAM "index_prefix", "namespace_name" FROM "SOURCE_SQL_STREAM_001" WHERE "namespace_name" = '${var.namespace_name}';
EOF
  inputs {

    name_prefix = "SOURCE_SQL_STREAM"

    kinesis_stream {
      resource_arn = data.aws_kinesis_stream.input_stream.arn
      role_arn     = aws_iam_role.kinesis_read_role.arn
    }

    schema {
      dynamic "record_columns" {
        for_each = var.data_columns

        content {
          mapping  = record_columns.value.mapping
          name     = record_columns.value.name
          sql_type = record_columns.value.sql_type
        }
      }

      record_encoding = "UTF-8"

      record_format {
        mapping_parameters {
          json {
            record_row_path = "$"
          }
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
      resource_arn = data.aws_kinesis_stream.output_stream.arn 
      role_arn     = aws_iam_role.kinesis_write_role.arn
    }
  }

  tags = {
    Environment = var.environment
  }
}
