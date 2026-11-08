# ==============================================================================
# Amazon ECR Repositories for MediGrid Microservices
# ==============================================================================

locals {
  services = [
    "medigrid/pharmacy-service",
    "medigrid/order-service",
    "medigrid/frontend"
  ]
}

resource "aws_ecr_repository" "services" {
  for_each             = toset(local.services)
  name                 = each.value
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = each.value
  }
}

# Output the repository URLs
output "ecr_repository_urls" {
  description = "The URLs of the MediGrid ECR repositories"
  value       = { for k, v in aws_ecr_repository.services : k => v.repository_url }
}
