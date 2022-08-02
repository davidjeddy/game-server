# Create and manage custom VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  # general
  cidr       = "10.0.0.0/16"
  create_igw = true
  name       = join(var.delimiter, [var.name, var.stage, random_string.root.id])

  # flow logs
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true

  # subnets
  azs             = [join("", [data.aws_region.current.name, "a"])]
  private_subnets = ["10.0.129.0/24"]
  public_subnets  = ["10.0.193.0/24"]

  tags = merge(
    var.tags,
    { Name = join(var.delimiter, [var.name, var.stage, random_string.root.id]) }
  )
}
