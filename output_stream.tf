module "stream" {
  source = "git::https://github.com/UKHomeOffice/acp-tf-kinesis-streams?ref=v0.1.4"

  stream_name      = var.output_stream_name
  shard_count      = var.output_stream_shard_count
  retention_period = var.output_stream_retention_period
  consumer_user    = var.output_stream_consumer_user
  producer_user    = var.output_stream_producer_user
  exporter_user    = var.output_stream_exporter_user

  tags = var.tags

}

output "consumer_access_key" {
  value = map(module.stream.stream_arn, module.stream.consumer_access_key)
}

output "consumer_secret_key" {
  value = map(module.stream.stream_arn, module.stream.consumer_secret_key)
}

output "producer_access_key" {
  value = map(module.stream.stream_arn, module.stream.producer_access_key)
}

output "producer_secret_key" {
  value = map(module.stream.stream_arn, module.stream.producer_secret_key)
}

output "cloudwatch_exporter_access_key" {
  value = map(module.stream.stream_arn, module.stream.cloudwatch_exporter_access_key)
}

output "cloudwatch_exporter_secret_key" {
  value = map(module.stream.stream_arn, module.stream.cloudwatch_exporter_secret_key)
}