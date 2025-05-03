# terraform/variables.tf

variable "aws_region" {
  description = "AWS region to deploy the application"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Name of the S3 bucket for application versions"
  type        = string
  default     = "transcript-summarizer-versions"
}

variable "groq_api_key" {
  description = "Groq API key for the application"
  type        = string
  sensitive   = false
}