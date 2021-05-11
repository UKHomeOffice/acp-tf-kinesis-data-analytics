resource "aws_kinesis_analytics_application" "analytics_application" {
  name = var.application_name


  code = <<EOT
CREATE OR REPLACE STREAM "${var.in_application_output_stream_name}" (index VARCHAR(32),
                                                                     namespace VARCHAR(32),
                                                                     audit_namespace VARCHAR(32),
                                                                     kubernetes VARCHAR(1000),
                                                                     message_json VARCHAR(10000),
                                                                     audit_json VARCHAR(3000),
                                                                     log_timestamp TIMESTAMP);
%{ for index in range(1, var.parallelism+1) ~}
CREATE OR REPLACE PUMP STREAM_PUMP_${format("%03.0f", index)} AS INSERT INTO "${var.in_application_output_stream_name}"
SELECT STREAM "index_prefix",
               "namespace_name",
               "audit_namespace_name",
               "kubernetes_data",
               "message_json",
               "audit_json",
               "log_timestamp"
FROM SOURCE_SQL_STREAM_${format("%03.0f", index)} WHERE SOURCE_SQL_STREAM_${format("%03.0f", index)}."namespace_name" ${var.selector};
%{ endfor ~}
EOT

  inputs {

    name_prefix = "SOURCE_SQL_STREAM"

    kinesis_stream {
      resource_arn = data.aws_kinesis_stream.input_stream.arn
      role_arn     = aws_iam_role.kinesis_read_role.arn
    }

    parallelism {
      count = var.parallelism
    }

    starting_position_configuration {
      starting_position = "NOW"
    }

    schema {
      record_encoding = "UTF-8"


      record_columns {
        mapping  = "$.kubernetes"
        name     = "kubernetes_data"
        sql_type = "VARCHAR(1000)"
      }
      record_columns {
        mapping  = "$.index_prefix"
        name     = "index_prefix"
        sql_type = "VARCHAR(32)"
      }
      record_columns {
        mapping  = "$.kubernetes.namespace_name"
        name     = "namespace_name"
        sql_type = "VARCHAR(32)"
      }
      record_columns {
        mapping  = "$.audit_json.objectRef.namespace"
        name     = "audit_namespace_name"
        sql_type = "VARCHAR(32)"
      }
      record_columns {
        mapping  = "$.message_json"
        name     = "message_json"
        sql_type = "VARCHAR(10000)"
      }
      record_columns {
        mapping  = "$.audit_json"
        name     = "audit_json"
        sql_type = "VARCHAR(3000)"
      }
      record_columns {
        mapping  = "$.time"
        name     = "log_timestamp"
        sql_type = "TIMESTAMP"
      }

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
    name = var.in_application_output_stream_name
    schema {
      record_format_type = "JSON"
    }

    kinesis_stream {
      resource_arn = module.stream.stream_arn
      role_arn     = aws_iam_role.kinesis_write_role.arn
    }
  }

  start_application = true

  tags = var.tags
}
