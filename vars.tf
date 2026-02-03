variable "vpc_cidr" {
  
}

variable "enable_dns_hostnames" {
  default = true
}

variable "project_name" {
  
}

variable "environment" {
  
}

variable "common_tags" {
  type = map
  default = {}
}

variable "tags" {
  
}

variable "vpc_tags" {
  default = {}
}

variable "igw_tags" {
  default = {}
}

variable "public_subnet_cidrs" {
  type = list 

  validation {
    condition = length(var.public_subnet_cidrs)== 2 
  error_message = "please provide 2 valid subnet cidrs "
}
}

variable "public_subnet_tags" {
  default = {}
}

variable "private_subnet_cidrs" {
  type = list
  validation {
    condition = length(var.private_subnet_cidrs)== 2 
    error_message= "please provide two valide subnet cidrs"
  }
}

variable "private_subnet_tags" {
  default = {}
}

variable "database_subnet_cidrs" {
  type = list 
  validation {
    condition = length(var.database_subnet_cidrs) == 2
    error_message = "pleasse provide 2 valid subent cidrs"
  }
}

variable "database_subnet_tags" {
  default = {}
}

variable "nat_gateway_tags" {
  default = {}
}

variable "public_route_tags" {
  default = {}
}

variable "private_route_tags" {
  default = {}
}

variable "database_route_tags" {
  default = {}
}

variable "is_peering_required" {
  default = false

}

variable "vpc_peering_tags" {
  default = {}
}