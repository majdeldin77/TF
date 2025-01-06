# Create and bootstrap kworker1 ec2 instance :
resource "aws_instance" "kworker1" {
  ami                         = var.ami-ubuntu
  instance_type               = "t3.large"
  key_name                    = aws_key_pair.ec2-key.key_name
  root_block_device {
    volume_type = "gp3"
    volume_size = 64
  }
  associate_public_ip_address = true
  private_ip                  = "10.100.10.11"
  vpc_security_group_ids      = [aws_security_group.sg.id]
  subnet_id                   = aws_subnet.subnet.id
  depends_on                  = [aws_instance.kmaster]

# Establishes connection to be used by all :
  connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("private-key.pem")
      host        = self.public_ip
  }

# Copy key & scripts to the worker-node : 
  provisioner "file" {
    source      = "private-key.pem"
    destination = "/home/ubuntu/private-key.pem"
  }
  provisioner "file" {
    source      = "kworker-setup.sh"
    destination = "/home/ubuntu/kworker-setup.sh"
  }
  provisioner "file" {
    source      = "join-setup.sh"
    destination = "/home/ubuntu/join-setup.sh"
  }

# Configure the worker-node :
  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname kworker1",
      "chmod 600 private-key.pem",
      "chmod +x kworker-setup.sh",
      "chmod +x join-setup.sh",
      "sed -i -e 's/\r$//' kworker-setup.sh",
      "sed -i -e 's/\r$//' join-setup.sh",
      "./kworker-setup.sh",
      "./join-setup.sh",
    ]
  }

  tags = {
    Name = "kworker1"
  }
}

# Create and bootstrap kworker2 ec2 instance :
resource "aws_instance" "kworker2" {
  ami                         = var.ami-ubuntu
  instance_type               = "t3.large"
  key_name                    = aws_key_pair.ec2-key.key_name
  root_block_device {
    volume_type = "gp3"
    volume_size = 128
  }
  associate_public_ip_address = true
  private_ip                  = "10.100.10.12"
  vpc_security_group_ids      = [aws_security_group.sg.id]
  subnet_id                   = aws_subnet.subnet.id
  depends_on                  = [aws_instance.kmaster]

# Establishes connection to be used by all :
  connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("private-key.pem")
      host        = self.public_ip
  }

# Copy key & scripts to the worker-node : 
  provisioner "file" {
    source      = "private-key.pem"
    destination = "/home/ubuntu/private-key.pem"
  }
  provisioner "file" {
    source      = "kworker-setup.sh"
    destination = "/home/ubuntu/kworker-setup.sh"
  }
  provisioner "file" {
    source      = "join-setup.sh"
    destination = "/home/ubuntu/join-setup.sh"
  }

# Configure the worker-node :
  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname kworker2",
      "chmod 600 private-key.pem",
      "chmod +x kworker-setup.sh",
      "chmod +x join-setup.sh",
      "sed -i -e 's/\r$//' kworker-setup.sh",
      "sed -i -e 's/\r$//' join-setup.sh",
      "./kworker-setup.sh",
      "./join-setup.sh",
    ]
  } 

  tags = {
    Name = "kworker2"
  }
}