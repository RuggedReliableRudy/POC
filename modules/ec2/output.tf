output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.cpe_app.id
}

output "private_ip" {
  description = "EC2 private IP address"
  value       = aws_instance.cpe_app.private_ip
}

output "iam_instance_profile" {
  description = "IAM instance profile attached to EC2"
  value       = var.instance_profile_name
}
