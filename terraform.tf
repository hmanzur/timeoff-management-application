terraform {
  required_version = ">= 0.12"
}

provider "aws" {
}

resource "aws_instance" "application" {
  # https://cloud-images.ubuntu.com/locator/ec2/
  ami           = "ami-07ebfd5b3428b6f4d"
  instance_type = "t2.micro"
  key_name      = "deployer-key"

  # key_name      = "${aws_key_pair.generated_key.key_name}"
  vpc_security_group_ids = [aws_security_group.instance.id]

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install ansible -y",
      "curl -sL https://deb.nodesource.com/setup_10.x | bash",
      "sudo apt install nodejs npm -y",
      "sudo npm install pm2 -g",
    ]
  }

  /* user_data = <<-EOT
    # update dependencies
    sudo apt update -y

    # install ansible
    sudo apt install ansible -y

    # download and install node repository
    curl -sL https://deb.nodesource.com/setup_10.x | bash

    # install node and
    sudo apt install nodejs npm -y

    # Install pm2 server
    sudo npm install pm2 -g
  EOT */

  tags = {
    Name = "Gorilla Test"
  }
}

variable "public_key" {
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = var.public_key
}

resource "aws_security_group" "instance" {
  name        = "gorilla"
  description = "SG for Gorilla test app"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "public_ip" {
  value = aws_instance.application.public_ip
}

