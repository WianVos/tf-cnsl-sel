# keys must be set in your environment and then passed to terraform using the -vars option
variable "aws_access_key" {
  default = ""
}

# keys must be set in your environment and then passed to terraform using the -vars option
variable "aws_secret_key" {
  default = ""
}

# we are using an european region ofcourse
variable "aws_region" {
  default = "eu-central-1"
}

variable "aws_ami" {
  default = "ami-b03ffedf"
}

# very open subnet :-)
variable "private_subnet_cidr" {
  default = "0.0.0.0/0"
}

# var name
variable "environment_name" {
  default = "deathstar"
}

#number of consul servers
variable "consul_server_count" {
  default = 2
}
