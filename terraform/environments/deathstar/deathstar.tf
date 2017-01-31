#compose variables

#Initialize the AWS provider
#
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

# retrieve the ami info from aws ..
# this makes the image selection a little more robust
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# configure an aws keypair to use
# keys are used from the ssh_keys folder located in the folder where this .tf file resides in
resource "aws_key_pair" "deathstar" {
  key_name   = "deathstar"
  public_key = "${file("./ssh_keys/rsa.pub")}"
}

# the basic security group for our deathstar consul hosts

resource "aws_security_group" "deathstar-consul" {
  name        = "deathstar-consul"
  description = "Consul internal traffic for The Deathstar"

  // These are for internal traffic
  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
  }

  egress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
  }

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "udp"
    self      = true
  }

  // These are for maintenance
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // This is for outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# this bit creates the instance
# pretty straight forward stuff

resource "aws_instance" "deathstar_consul" {
  instance_type = "t2.small"

  tags {
    name = "deathstar"
  }

  ami               = "${data.aws_ami.ubuntu.id}"
  count             = "${var.consul_server_count}"
  key_name          = "${aws_key_pair.deathstar.id}"
  security_groups   = ["${aws_security_group.deathstar-consul.name}"]
  source_dest_check = false

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("ssh_keys/rsa")}"
    timeout     = "1m"
    agent       = false
  }

  tags {
    Name       = "deathstar-consul-${count.index}"
    ConsulRole = "Server"
  }

  #
  provisioner "file" {
    source      = "./environments/deathstar/files/consul.service"
    destination = "/tmp/consul.service"
  }

  # put the servercount and adresses in a file on the instance
  provisioner "remote-exec" {
    inline = [
      "echo ${var.consul_server_count} > /tmp/consul_server_count",
      "echo ${aws_instance.deathstar_consul.0.private_dns} > /tmp/consul-server-addr",
    ]
  }

  # install the service ..
  # broken up in to three functional pieces
  provisioner "remote-exec" {
    scripts = [
      "./environments/deathstar/scripts/consul_install.sh",
      "./environments/deathstar/scripts/consul_service.sh",
      "./environments/deathstar/scripts/consul_iptables.sh",
      "./environments/deathstar/scripts/terraform_install.sh",
      "./environments/deathstar/scripts/ansible_install.sh",
    ]
  }

  provisioner "file" {
    source      = "./ssh_keys/rsa"
    destination = "/home/ubuntu/.ssh/rsa"
  }

  provisioner "file" {
    source      = "./ssh_keys/rsa"
    destination = "/opt/ansible/keys/rsa"
  }

  provisioner "file" {
    source      = "./ssh_keys/rsa.pub"
    destination = "/opt/ansible/keys/rsa.pub"
  }

  provisioner "file" {
    source      = "./environments/deathstar/files/ansible.cfg"
    destination = "/opt/ansible/ansible.cfg"
  }
}
