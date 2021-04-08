module "stream" {
  source = "git::https://github.com/UKHomeOffice/acp-tf-kinesis-streams?ref=v0.1.4"

  stream_name      = var.output_stream_name
  shard_count      = var.output_stream_shard_count
  retention_period = 24
  consumer_user    = true
  producer_user    = false
  exporter_user    = true

  tags = var.tags

}

output "consumer_access_key" {
  value = module.stream.consumer_access_key
}

output "consumer_secret_key" {
  value = module.stream.consumer_secret_key
}

output "cloudwatch_exporter_access_key" {
  value = module.stream.cloudwatch_exporter_access_key
}

output "cloudwatch_exporter_secret_key" {
  value = module.stream.cloudwatch_exporter_secret_key
}
