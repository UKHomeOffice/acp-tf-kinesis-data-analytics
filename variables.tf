variable "analytics_application_name" {
  description = "The name of the Kinesis analytics application."
  type        = string
}

variable "namespaces" {
  description = "The namespaces from which you want to retrive logs."
  type        = set(string)
}

variable "input_kinesis_stream_name" {
  description = "The name of the source Kinesis datastream"
  default     = "acp-log-stream"
}

variable "environment" {
  type = string
}
