data "aws_s3_bucket_object" "ec2_key_file" {
  bucket = var.bucket_name
  key    = "${var.key_name}.pem"
}

resource "aws_instance" "application" {
  # https://cloud-images.ubuntu.com/locator/ec2/
  ami                         = "ami-07ebfd5b3428b6f4d"
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.instance.id]

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install ansible nodejs npm git -y"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = aws_instance.application.public_ip
      private_key = file("${var.key_name}.pem")
    }
  }

  lifecycle {
    create_before_destroy = true
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