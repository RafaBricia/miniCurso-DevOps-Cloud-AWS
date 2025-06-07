resource "aws_vpc" "this" {
  cidr_block = var.vpc.cidr_block

  tags = {
    name = var.vpc.name
  }
}