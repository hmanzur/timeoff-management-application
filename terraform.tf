terraform {
  required_version = ">= 0.12"
  backend "s3" {
    bucket = "ci-gorilla-test-habib"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

variable "ec2_key" {
  type        = string
  default     = "gorilla_ec2_key"
  description = "Pem key name"
}

data "aws_s3_bucket_object" "ec2_key_file" {
  bucket = "ci-gorilla-test-habib"
  key    = "${var.ec2_key}.pem"
}

resource "aws_instance" "application" {
  # https://cloud-images.ubuntu.com/locator/ec2/
  ami                         = "ami-07ebfd5b3428b6f4d"
  instance_type               = "t2.micro"
  key_name                    = var.ec2_key
  associate_public_ip_address = true

  # key_name      = "${aws_key_pair.generated_key.key_name}"
  vpc_security_group_ids = [aws_security_group.instance.id]

  provisioner "local-exec" {
    command = "sudo apt-get install awscli -y && aws s3 cp s3://${data.aws_s3_bucket_object.ec2_key_file.bucket}/${var.ec2_key}.pem artifacts/${var.ec2_key}.pem"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install ansible nodejs npm git -y"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = aws_instance.application.public_ip
      private_key = file("artifacts/${var.ec2_key}.pem")
    }
  }

  tags = {
    Name = "Gorilla Test"
  }
}

resource "aws_security_group" "instance" {
  name        = "gorilla"
  description = "SG for Gorilla test app"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "local_file" "ip" {
  content  = aws_instance.application.public_ip
  filename = "${path.module}/artifacts/public_ip"
}

output "public_ip" {
  value = aws_instance.application.public_ip
}

