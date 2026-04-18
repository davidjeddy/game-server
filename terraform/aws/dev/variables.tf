## EC2

variable "base_ami" {
  default     = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20220118"
  description = "Base machine image to use for the server"
  type        = string
}

variable "instance_type" {
  default     = "m5.large"
  description = "Type and size of EC2 instance"
  type        = string
}

## Generic

variable "delete_timeout" {
  default     = 7
  description = "Default timeout in days when deleting protected resources"
  type        = number
}

variable "name" {
  default     = "game-server"
  description = "(required) The application or project name"
  type        = string
}

variable "region" {
  default     = "us-east-1"
  type        = string
  description = "(optional) describe your variable"
}


variable "stage" {
  description = "The stage; aka environment"
  type        = string
  default     = "dev"
}

variable "delimiter" {
  description = "Delimiter character"
  type        = string
  default     = "-"
}

variable "source_cidr" {
  default     = ["0.0.0.0/0"]
  type        = list(any)
  description = "(required) CIDR ranges to allow traffic from"
}

# No defaults

variable "access_key" {
  type        = string
  description = "(required) AWS API access key id"
}


variable "aws_acct_id" {
  description = "AWS account ID"
  type        = number
}

variable "tags" {
  description = "Default shared tags"
  type        = map(any)
}

variable "secret_key" {
  type        = string
  description = "(required) AWS API secret key id"
}
