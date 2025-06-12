provider "aws" {
  region = var.aws_region
}

# Use the default VPC
data "aws_vpc" "default" { default = true }

# Latest Amazon Linux 2 AMI
data "aws_ami" "al2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# SSH key pair
resource "aws_key_pair" "minecraft" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

# Security group opening Minecraft port
resource "aws_security_group" "minecraft_sg" {
  name        = "minecraft-sg"
  description = "Allow Minecraft TCP 25565"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = var.mc_port
    to_port     = var.mc_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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

# EC2 instance
resource "aws_instance" "minecraft" {
  ami                         = data.aws_ami.al2.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.minecraft.key_name
  vpc_security_group_ids      = [aws_security_group.minecraft_sg.id]
  associate_public_ip_address = true
  tags = { Name = "minecraft-server" }


  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.private_key_path)
    timeout     = "2m"
  }

  provisioner "file" {
    source      = "../bootstrap.sh"
    destination = "/home/ec2-user/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ec2-user/bootstrap.sh",
      "sudo /home/ec2-user/bootstrap.sh"
    ]
  }
}
