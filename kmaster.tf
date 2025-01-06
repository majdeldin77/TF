# Create Kmaster interface :
resource "aws_network_interface" "kmaster" {
  subnet_id       = aws_subnet.subnet.id
  private_ips     = ["10.100.10.7"]
  security_groups = [aws_security_group.sg.id]
}

# Elastic IP :
resource "aws_eip" "kmaster" {}

# Elastic IP Association :
resource "aws_eip_association" "kmaster" {
  network_interface_id = aws_network_interface.kmaster.id
  allocation_id = aws_eip.kmaster.id
}

# Create and bootstrap kmaster ec2 instance :
resource "aws_instance" "kmaster" {
  ami                         = var.ami-ubuntu
  instance_type               = "t3.large"
  key_name                    = aws_key_pair.ec2-key.key_name
  root_block_device {
    volume_type = "gp3"
    volume_size = 64
  }
  network_interface {
        device_index            = 0
        network_interface_id    = aws_network_interface.kmaster.id
  }
  
# Establishes connection to be used by all :
  connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("private-key.pem")
      host        = self.public_ip
  }

# Copy the script from local to the master-node :
  provisioner "file" {
    source      = "kmaster-setup.sh"
    destination = "/home/ubuntu/kmaster-setup.sh"
  }

# Configure the master-node :
  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname kmaster",
      "chmod +x kmaster-setup.sh",
      "sed -i -e 's/\r$//' kmaster-setup.sh", #convert script from windows to unix format.
      "./kmaster-setup.sh",
    ]
  }

  tags = {
    Name = "kmaster"
  }
}