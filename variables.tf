## EC2

variable key_name {
  type        = string
  description = "SSH PEM keypair name"
}

variable instance_type {
  description = "Type and size of EC2 instance"
  type        = string
}

## Generic

variable aws_acct_id {
  description = "AWS account ID"
  type        = number
}

variable name {
  default     = "satisfactory"
  description = "Application name"
  type        = string
}

variable stage {
  description = "The stage; aka environment"
  type        = string
  default     = "dev"
}

variable delimiter {
  description = "Delimiter character"
  type        = string
  default     = "-"
}

variable tags {
  description = "Default shared tags"
  type        = map
}

## VPC

variable availability_zone {
  description = "Default AZ"
  type        = string
}

variable vpc_id {
  description = "VPC to launch resources into"
  type        = string
}

variable region {
  description = "AWS region"
  type        = string
}

### Route 53

variable route53_zone {
  description = "DNS zone"
  type        = string
}
