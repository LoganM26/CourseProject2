output "public_ip" {
  value       = aws_instance.minecraft.public_ip
  description = "Minecraft server public IP"
}

