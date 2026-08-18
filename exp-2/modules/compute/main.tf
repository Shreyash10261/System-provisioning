resource "aws_instance" "web" {
  count = var.web_count

  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_pair_name
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [var.web_security_group_id]
  associate_public_ip_address = true
  user_data_replace_on_change = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted = true
  }

  user_data = <<-USERDATA
    #!/bin/bash
    set -euxo pipefail
    (dnf install -y httpd || yum install -y httpd)
    cat > /var/www/html/index.html <<'HTML'
    <!doctype html>
    <html><body><h1>System Provisioning Lab - Web Tier</h1><p>Provisioned by Terraform.</p></body></html>
    HTML
    systemctl enable --now httpd
  USERDATA

  tags = {
    Name = "${var.project_name}-web-${count.index + 1}"
    Tier = "web"
  }
}

# This instance has no public IP and is reachable on MySQL port 3306 only from
# the web security group. Use a database-ready AMI or a private package source
# if the lab also requires a running MySQL/MariaDB service.
resource "aws_instance" "db" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_pair_name
  subnet_id                   = var.private_subnet_id
  vpc_security_group_ids      = [var.db_security_group_id]
  associate_public_ip_address = false

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name = "${var.project_name}-db-1"
    Tier = "database"
  }
}
