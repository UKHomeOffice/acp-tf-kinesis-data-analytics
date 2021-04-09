module "stream" {
  source = "git::https://github.com/UKHomeOffice/acp-tf-kinesis-streams?ref=v0.1.4"

  stream_name      = var.output_stream_name
  shard_count      = var.output_stream_shard_count
  retention_period = 24
  consumer_user    = true
  producer_user    = false
  exporter_user    = false

  tags = var.tags

}

output "consumer_access_key" {
  value = map(module.stream.stream_arn, module.stream.consumer_access_key)
}

output "consumer_secret_key" {
  value = map(module.stream.stream_arn, module.stream.consumer_secret_key)
}
