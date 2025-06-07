resource "aws_eip" "this" {
  domain = "vpc"
  tags = {
    name = var.vpc.nat_gateway_name
  }
}