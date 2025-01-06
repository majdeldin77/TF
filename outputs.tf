# Print the Public IP of the master-node :
output "kmaster-IP" {
  value = aws_eip.kmaster.public_ip
}