provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      ManagedBy  = "Terraform"
      Experiment = "Experiment-2"
      Project    = var.project_name
    }
  }
}
