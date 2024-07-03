provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}

resource "aws_security_group" "gha-tf-ans-demo-control" {
  name        = "gha-tf-ans-demo-control"
  description = "Security Group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "gha-tf-ans-demo-targets" {
  name        = "gha-tf-ans-demo-targets"
  description = "Security Group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key"
  default     = "~/terraform-aws/aws-key.pem"
}

resource "aws_instance" "master_node" {
  ami                    = "ami-0aa7d40eeae50c9a9"
  instance_type          = "t2.micro"
  key_name               = "aws-key"
  vpc_security_group_ids = [aws_security_group.gha-tf-ans-demo-control.id]

  tags = {
    Name = "master_node"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'hello world!'",
      "pwd",
      "sudo yum update -y",
      "sudo amazon-linux-extras install ansible2 -y",
    ]
    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.ssh_private_key_path)
    }
  }
}

