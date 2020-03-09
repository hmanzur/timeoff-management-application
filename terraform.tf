terraform {
  required_version = ">= 0.12"
  backend "s3" {
    bucket = "ci-gorilla-test-habib"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
}

# https://www.terraform.io/docs/providers/aws/d/s3_bucket_object.html
# data "aws_s3_bucket_object" "bootstrap_script" {
#   bucket = "ci-gorilla-test-habib"
#   key    = "ec2-bootstrap-script.sh"
# }

resource "aws_instance" "application" {
  # https://cloud-images.ubuntu.com/locator/ec2/
  ami           = "ami-07ebfd5b3428b6f4d"
  instance_type = "t2.micro"
  key_name      = "gorilla_ec2_key"

  user_data = "${file("scripts/user-data.txt")}"

  # key_name      = "${aws_key_pair.generated_key.key_name}"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]

  tags = {
    Name = "Gorilla Test"
  }
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
  value = "${aws_instance.application.public_ip}"
}

