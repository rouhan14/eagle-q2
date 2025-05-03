# terraform/main.tf

provider "aws" {
  region = var.aws_region
}

# S3 bucket for the application version
resource "aws_s3_bucket" "app_bucket" {
  bucket = var.bucket_name
}

# Elastic Beanstalk application
resource "aws_elastic_beanstalk_application" "transcript_summarizer" {
  name        = "transcript-summarizer"
  description = "Meeting transcript summarization service using Groq API"
}

# Elastic Beanstalk environment
resource "aws_elastic_beanstalk_environment" "transcript_summarizer_env" {
  name                = "transcript-summarizer-env"
  application         = aws_elastic_beanstalk_application.transcript_summarizer.name
  solution_stack_name = "64bit Amazon Linux 2 v3.5.0 running Python 3.8"

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "GROQ_API_KEY"
    value     = var.groq_api_key
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "SingleInstance"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.eb_instance_profile.name
  }

  setting {
    namespace = "aws:elasticbeanstalk:container:python"
    name      = "WSGIPath"
    value     = "app:app"
  }
}

# IAM role and instance profile for Elastic Beanstalk
resource "aws_iam_role" "eb_instance_role" {
  name = "transcript-summarizer-eb-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eb_web_tier" {
  role       = aws_iam_role.eb_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_instance_profile" "eb_instance_profile" {
  name = "transcript-summarizer-eb-instance-profile"
  role = aws_iam_role.eb_instance_role.name
}

# Output the URL of the Elastic Beanstalk environment
output "application_url" {
  value = aws_elastic_beanstalk_environment.transcript_summarizer_env.endpoint_url
}