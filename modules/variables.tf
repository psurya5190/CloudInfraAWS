variable "vpc_id" {}
variable "vpc_cidr_block" {}
variable "private_subnets_count" {}
variable "public_subnets_count" {}
variable "availability_zones" {}
variable "public_subnets" {}
variable "vpc_name" {
  default = ""
}
variable "author" {
  default = ""
}
variable "public_key" {
  default = ""
} 