variable "vpc" {
  type = object({
    name                     = string
    cidr_block               = string
    internet_gateway_name    = string
    public_route_table_name  = string
    private_route_table_name = string
    nat_gateway_name         = string
    public_subnets = list(object({
      name                    = string
      cidr_block              = string
      availability_zone       = string
      map_public_ip_on_launch = bool
    }))
    private_subnets = list(object({
      name                    = string
      cidr_block              = string
      availability_zone       = string
      map_public_ip_on_launch = bool
    }))
  })

  default = {
    name                     = "live-minicurso-deveops-cloud-main-vpc"
    cidr_block               = "10.0.0.0/24"
    internet_gateway_name    = "live-minicurso-deveops-cloud-internet_gateway"
    public_route_table_name  = "live-minicurso-deveops-cloud-route_table-public"
    private_route_table_name = "live-minicurso-deveops-cloud-route_table-private"
    nat_gateway_name         = "live-minicurso-deveops-cloud-nat_gateway"
    public_subnets = [
      {
        name                    = "live-minicurso-deveops-cloud-public-subnet-1a"
        cidr_block              = "10.0.0.0/26"
        availability_zone       = "us-west-1a"
        map_public_ip_on_launch = true
      },
      {
        name                    = "live-minicurso-deveops-cloud-public-subnet-1c"
        cidr_block              = "10.0.0.64/26"
        availability_zone       = "us-west-1c"
        map_public_ip_on_launch = true
      }
    ]
    private_subnets = [
      {
        name                    = "live-minicurso-deveops-cloud-private-subnet-1a"
        cidr_block              = "10.0.0.128/26"
        availability_zone       = "us-west-1a"
        map_public_ip_on_launch = false
      },
      {
        name                    = "live-minicurso-deveops-cloud-private-subnet-1c"
        cidr_block              = "10.0.0.192/26"
        availability_zone       = "us-west-1c"
        map_public_ip_on_launch = false
      }
    ]
  }
}
