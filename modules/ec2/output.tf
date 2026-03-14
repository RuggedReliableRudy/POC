############################################################
# EC2 MODULE OUTPUTS
############################################################

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.cpe_app.id
}

output "private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.cpe_app.private_ip
}

output "security_group_id" {
  description = "Security group ID attached to EC2"
  value       = aws_security_group.ec2_sg.id
}

output "iam_instance_profile" {
  description = "IAM instance profile attached to EC2"
  value       = aws_iam_instance_profile.cpe_ec2_profile.name
}
