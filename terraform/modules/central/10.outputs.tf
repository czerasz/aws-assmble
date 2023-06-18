output "ssm_document_arn" {
  description = "AWS SSM Document ARN"
  value       = aws_ssm_document.this.arn
}
