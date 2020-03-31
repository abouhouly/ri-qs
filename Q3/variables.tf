#
## variables file
#

variable "houly_ecs_cluster" {
 description = "ECS cluster name"
}

variable "ecs_key_pair_name" {
 description = "EC2 instance key pair name"
}

variable "region" {
 description = "AWS region"
}

variable "availability_zone" {
 description = "availability zone used in the London Region"
 default = {
   eu-west-2 = "eu-west-2"
 }
}

variable "image_id" {
  description = "the AMI id of the ec2 instance"
}

########################### VPC Config ################################

variable "houly_vpc" {
 description = "VPC name for houly environment"
}

variable "houly_network_cidr" {
 description = "IP addressing for houly Network"
}

variable "houly_public_01_cidr" {
 description = "Public 0.0 CIDR for externally accessible subnet"
}

variable "houly_public_02_cidr" {
 description = "Public 0.0 CIDR for externally accessible subnet"
}

########################### Autoscale Config ################################

variable "max_instance_size" {
 description = "Maximum number of instances in the cluster"
}

variable "min_instance_size" {
 description = "Minimum number of instances in the cluster"
}

variable "desired_capacity" {
 description = "Desired number of instances in the cluster"
}
