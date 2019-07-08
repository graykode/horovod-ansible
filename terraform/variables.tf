variable region {
  default = "ap-northeast-2"
}

variable zone {
  default = "ap-northeast-2a"
}

variable number_of_worker{
  description = "The number of worker nodes"
  default = 2
}

variable master_instance_type {
  default = "t2.small"
}

variable worker_instance_type {
  default = "t2.small"
}

variable vpc_name {
  description = "Name of the VPC"
  default = "horovod"
}

variable volume_type {
  description = "The type of volume"
  default = "gp2"
}

variable volume_size {
  description = "The size of the volume in gibibytes (GiB)."
  default = 10
}

variable owner {
  default = "graykode"
}

## DO NOT CHANGE BELOW

variable vpc_cidr {
  default = "10.43.0.0/16"
}

variable control_cidr {
  description = "CIDR for maintenance: inbound traffic will be allowed from this IPs"
  default = "0.0.0.0/0"
}

locals {
  default_keypair_public_key = "${file("horovod.pub")}"
}

variable default_keypair_name {
  description = "Name of the KeyPair used for all nodes"
  default = "horovod"
}

variable amis {
  description = "Default AMIs to use for nodes depending on the region"
  type = "map"
  default = {
    ap-northeast-2 = "ami-067c32f3d5b9ace91"
    ap-northeast-1 = "ami-0567c164"
    ap-southeast-1 = "ami-a1288ec2"
    cn-north-1 = "ami-d9f226b4"
    eu-central-1 = "ami-8504fdea"
    eu-west-1 = "ami-0d77397e"
    sa-east-1 = "ami-e93da085"
    us-east-1 = "ami-40d28157"
    us-west-1 = "ami-6e165d0e"
    us-west-2 = "ami-a9d276c9"
  }
}