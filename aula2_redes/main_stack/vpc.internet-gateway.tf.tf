resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    name = var.vpc.internet_gateway_name
  }
}