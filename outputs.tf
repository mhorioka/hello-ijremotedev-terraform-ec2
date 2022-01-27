output "remotedev_ec2_ip" {
  value = aws_instance.remotedev_ec2.public_ip
}