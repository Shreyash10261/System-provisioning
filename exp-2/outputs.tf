output "web_public_ips" {
  description = "Public IPv4 addresses of the web tier instances."
  value       = module.compute.web_public_ips
}

output "db_private_ip" {
  description = "Private IPv4 address of the database-tier instance."
  value       = module.compute.db_private_ip
}

output "vpc_id" {
  description = "ID of the experiment VPC."
  value       = module.network.vpc_id
}
