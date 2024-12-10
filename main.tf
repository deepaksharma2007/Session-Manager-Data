terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16" 		# aws driver/plugin version stored in .terraform folder
    }
  }

  required_version = ">= 1.10.0" 	# terraform version 
}

# Gives Provider 
provider "aws" {
  region = "ap-south-1"
  profile = "deep-terraform"
}

# Store VPC ID in a variable 
variable "myvpc" {
  type = string
  default = "vpc-a8766ac0"
}

# Create Security Group
resource "aws_security_group" "web_sg" {
  name        = "web-security-group"
  description = "Allow SSH, HTTP, and HTTPS traffic"
  vpc_id      = var.myvpc # Replace or define this variable if you're using a specific VPC

  # Ingress Rules
  ingress {
    description = "Allow SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress Rule (Allow all outbound traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allows all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "WebServerSecurityGroup"
  }
}
/*
output "securitygroup_ID" {
 value = aws_security_group.web_sg.id
}
*/

# Add ec2 instance resource
resource "aws_instance" "web" {
  ami           = "ami-0614680123427b75e"
  instance_type = "t2.micro"
  key_name   = "marvikkey"
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "HelloWorld-OS"
  }
}

output "myos_public_IP" {
  value = aws_instance.web.public_ip
}

/*
output "myos_az"{
  value = aws_instance.web.availability_zone
}
*/
# Create EBS volume of 1GB
resource "aws_ebs_volume" "myos_ebs_volume" {
  availability_zone = aws_instance.web.availability_zone
  size              = 1

  tags = {
    Name = "HelloWorld-Volume"
  }
}

/*
# To retrive volume ID 
output myebs_vol {
  value = aws_ebs_volume.myos_ebs_volume
}
*/

# Attach this volume to Instance 
resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.myos_ebs_volume.id}"
  instance_id = "${aws_instance.web.id}"
}

# Setup webserver 
resource "null_resource" "Setup_webserver" {
   connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/DELL/Downloads/marvikkey.pem")
    host     = aws_instance.web.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd -y" ,
      "sudo systemctl enable httpd --now" ,
       "echo 'Welcome to Deepak Server' | sudo tee /var/www/html/index.html > /dev/null",
    ]
  }
}

resource "null_resource" "Open_Website"{
   provisioner "local-exec" {
    command = "chrome ${aws_instance.web.public_ip}"
  }
}