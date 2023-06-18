variable "name" {
  type        = string
  description = "Name used to identify resources"
}

variable "tags" {
  type        = map(string)
  description = "AWS tags"
  default     = {}
}

variable "s3_bucket_name" {
  type        = string
  description = "Name of existing AWS S3 bucket"
}
