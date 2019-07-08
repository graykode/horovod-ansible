provider "aws" {
  region = "${var.region}"
}

######################
# SET AWS-VPC
######################

resource "aws_vpc" "horovod" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags = "${merge(
    map(
        "Name", "${var.vpc_name}",
        "Owner", "${var.owner}"
    )
  )}"
}

resource "aws_vpc_dhcp_options" "dns_resolver" {
  domain_name = "${var.region}.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = "${merge(
    map(
        "Name", "${var.vpc_name}",
        "Owner", "${var.owner}"
    )
  )}"
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id ="${aws_vpc.horovod.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.dns_resolver.id}"
}

resource "aws_key_pair" "default_keypair" {
  key_name = "${var.default_keypair_name}"
  public_key = "${local.default_keypair_public_key}"
}

resource "aws_subnet" "horovod" {
  vpc_id = "${aws_vpc.horovod.id}"
  cidr_block = "${var.vpc_cidr}"
  availability_zone = "${var.zone}"

  tags = "${merge(
    map(
        "Name", "${var.vpc_name}",
        "Owner", "${var.owner}"
    )
  )}"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.horovod.id}"

  tags = "${merge(
    map(
        "Name", "${var.vpc_name}",
        "Owner", "${var.owner}"
    )
  )}"
}

resource "aws_route_table" "horovod" {
   vpc_id = "${aws_vpc.horovod.id}"

   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = "${aws_internet_gateway.gw.id}"
   }

  tags = "${merge(
    map(
        "Name", "${var.vpc_name}",
        "Owner", "${var.owner}"
    )
  )}"
}

resource "aws_route_table_association" "horovod" {
  subnet_id = "${aws_subnet.horovod.id}"
  route_table_id = "${aws_route_table.horovod.id}"
}

resource "aws_security_group" "horovod" {
  vpc_id = "${aws_vpc.horovod.id}"
  name = "horovod"

  # Allow all outbound
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all internal
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  # Allow all traffic from control host IP
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["${var.control_cidr}"]
  }

  tags = "${merge(
    map(
        "Name", "${var.vpc_name}",
        "Owner", "${var.owner}"
    )
  )}"
}

######################
# BOOTSTRAP EC2
######################

resource "aws_instance" "worker" {
  count = "${var.number_of_worker}"
  ami = "${lookup(var.amis, var.region)}"
  instance_type = "${var.worker_instance_type}"

  #user_data = "${data.template_file.worker-userdata.rendered}"

  subnet_id = "${aws_subnet.horovod.id}"
  private_ip = "${cidrhost(var.vpc_cidr, 30 + count.index)}"
  associate_public_ip_address = true # Instances have public, dynamic IP
  source_dest_check = false # TODO Required??

  root_block_device {
      volume_type = "${var.volume_type}"
      volume_size = "${var.volume_size}"
      delete_on_termination = "true"
  }

  availability_zone = "${var.zone}"
  vpc_security_group_ids = ["${aws_security_group.horovod.id}"]
  key_name = "${var.default_keypair_name}"

  tags = "${merge(
    map(
        "Owner", "${var.owner}",
        "Name", "worker-${count.index}"
      )
  )}"
}

output "horovod_workers_public_ip" {
  value = "${join(",", aws_instance.worker.*.public_ip)}"
}

resource "aws_instance" "master" {
  count = 1
  ami = "${lookup(var.amis, var.region)}"
  instance_type = "${var.master_instance_type}"

  #user_data = "${data.template_file.master-userdata.rendered}"

  subnet_id = "${aws_subnet.horovod.id}"
  private_ip = "10.43.0.40"
  associate_public_ip_address = true # Instances have public, dynamic IP
  source_dest_check = false # TODO Required??

  root_block_device {
      volume_type = "${var.volume_type}"
      volume_size = "${var.volume_size}"
      delete_on_termination = "true"
  }

  availability_zone = "${var.zone}"
  vpc_security_group_ids = ["${aws_security_group.horovod.id}"]
  key_name = "${var.default_keypair_name}"

  tags = "${merge(
    map(
        "Owner", "${var.owner}",
        "Name", "master"
      )
  )}"
}

output "horovod_master_public_ip" {
  value = "${aws_instance.master.public_ip}"
}