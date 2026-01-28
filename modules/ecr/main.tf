resource "aws_ecr_repository" "this" {

  name                 = var.name
  image_tag_mutability = var.image_tag_mutability
  force_delete         = var.force_delete  # Add this line

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = var.encryption_type
    kms_key         = var.encryption_type == "KMS" ? var.kms_key : null
  }

  tags = var.tags
}
