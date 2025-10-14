variable "name" {
  type = string
}

variable "region" {
  description = "AWS region for SSM Parameter Store"
  type        = string
  default     = "us-east-1"
}


variable "ami_id" {
  description = "AMI ID to use (Amazon Linux 2 or Ubuntu)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "Subnet ID to launch instance in"
  type        = string
}

variable "security_group_id" {
  description = "Security group to attach"
  type        = string
}

variable "key_name" {
  description = "Existing EC2 key pair name"
  type        = string
}

variable "image_url" {
  description = "Docker image to run (ECR or DockerHub)"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
