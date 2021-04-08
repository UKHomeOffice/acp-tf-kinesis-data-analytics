variable "application_name" {
  description = "The name of the Kinesis analytics application."
  type        = string
}

variable "selector" {
  description = "The argument passed to the WHERE operator, e.g. \"namespace_name\" LIKE 'dev-%'"
  type        = string
}

variable "input_kinesis_stream_name" {
  description = "The name of the source Kinesis datastream"
  default     = "acp-log-stream"
}

variable "in_application_output_stream_name" {
  default = "DESTINATION_STREAM"
}

variable "output_kinesis_stream_name" {
  description = "The name of the destination Kinesis datastream"
}

variable "tags" {
 type = map(string) 
}