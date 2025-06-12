variable "aws_region" {
  description = "AWS region"
  default     = "us-west-2"
}

variable "key_name" {
  description = "SSH key pair name"
  default     = "minecraft-key"
}

variable "public_key_path" {
  description = "Path to SSH public key"
  default     = "~/.ssh/id_rsa.pub"
}

variable "private_key_path" {
  description = "Path to SSH private key"
  default     = "~/.ssh/id_rsa"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.small"
}

variable "mc_port" {
  description = "Minecraft port"
  default     = 25565
}
