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

variable "eks" {
  type = object({
    name = string
    role_name = string
    version = string
    enabled_cluster_log_types = list(string)
    access_config_authentication_mode = string
    node_group_role_name = string
    node_group_name = string 
    node_group_instance_types = list(string)
    node_group_capacity_type = string
    scaling_config_desired_size = number
    scaling_config_max_size = number
    scaling_config_min_size = number
  })

  default = {
    name = "live-minicurso-deveops-cloud-eks_cluster"
    role_name = "minicurso-deveops-cloud-eks-Role"
    version = "1.33"
    enabled_cluster_log_types = [
        "api",
        "audit",
        "authenticator",
        "controllerManager",
        "scheduler"
    ]
    access_config_authentication_mode = "API_AND_CONFIG_MAP"
    node_group_role_name = "minicurso-deveops-cloud-eks_ng-Role-NEW"
    node_group_name = "live-minicurso-deveops-cloud-eks_cluster-ng"
    node_group_instance_types = ["t2.micro"]
    node_group_capacity_type = "ON_DEMAND"
    scaling_config_desired_size = 2
    scaling_config_max_size = 2
    scaling_config_min_size = 2
  }


}
  variable "ecr_repositories" {
    type = list(object({
      name                 = string
      image_tag_mutability = string
      force_delete = bool
  }))

  default = [
    {
    name                 = "minicursodevopscloud-aula03/production/frontend"
    image_tag_mutability = "MUTABLE"
    force_delete = true
    },
    {
    name                 = "minicursodevopscloud-aula03/production/backend"
    image_tag_mutability = "MUTABLE"
    force_delete = true
    }
  ]
  } 