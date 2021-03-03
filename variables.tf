variable "analytics_application_name" {
  description = "The name of the Kinesis analytics application."
  type        = string
}

variable "namespace_name" {
  description = "The namespace from which you want to retrive logs from."
  type        = string
}

variable "data_columns" {
  description = "The data columns for the schema"
  type = list(object({
    mapping  = string
    name     = string
    sql_type = string
  }))
}

variable "input_kinesis_stream" {
    description = "The source Kinesis datastream"
    default = "acp-log-stream"
}

variable "in_application_output_stream" {
  description = "The name of the in application stream"
  type        = string
}

variable "output_kinesis_stream_arn" {
  description = "The name of the Kinesis stream to output the resulting logs to"
  type        = string
}