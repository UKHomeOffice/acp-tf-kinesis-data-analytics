resource "aws_kinesis_analytics_application" "analytics_application" {
  name = var.analytics_application_name

  code = <<EOT
%{for namespace in var.namespaces~}
-- ns ${namespace}
CREATE OR REPLACE STREAM "${replace(namespace, "-", "_")}" (index VARCHAR(32), 
                                        namespace VARCHAR(32), 
                                        kubernetes VARCHAR(500), 
                                        message_json VARCHAR(3000), 
                                        audit_json VARCHAR(3000), 
                                        log_timestamp TIMESTAMP); 
CREATE OR REPLACE PUMP "STREAM_PUMP_${replace(namespace, "-", "_")}" AS INSERT INTO "${replace(namespace, "-", "_")}"
SELECT STREAM "index_prefix", 
               "namespace_name", 
               "kubernetes_data", 
               "message_json", 
               "audit_json", 
               "log_timestamp" 
FROM "SOURCE_SQL_STREAM_001" WHERE "namespace_name" = '${namespace}';
%{endfor~}
EOT

  inputs {

    name_prefix = "SOURCE_SQL_STREAM"

    kinesis_stream {
      resource_arn = data.aws_kinesis_stream.input_stream.arn
      role_arn     = aws_iam_role.kinesis_read_role.arn
    }

    schema {
      record_encoding = "UTF-8"

      record_columns {
        mapping  = "$.kubernetes"
        name     = "kubernetes_data"
        sql_type = "VARCHAR(500)"
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
        mapping  = "$.message_json"
        name     = "message_json"
        sql_type = "VARCHAR(3000)"
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

  dynamic "outputs" {
    for_each = var.namespaces
    content {
      name = replace(outputs.value, "-", "_")
      
      schema {
        record_format_type = "JSON"
      }

      kinesis_stream {
        resource_arn = "arn:aws:kinesis:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:stream/${outputs.value}"
        role_arn     = aws_iam_role.kinesis_write_role[outputs.value].arn
      }
    }
  }

  tags = {
    Environment = var.environment
  }
}
