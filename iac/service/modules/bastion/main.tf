data "aws_ami" "amazon-linux-2" {
  most_recent = true
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }


  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}
resource "aws_security_group" "bastion_sg" {
  name        = "Last-stop-bastion"
  description = "Example security group for bastion instance"
  vpc_id      = var.vpc_config.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["24.112.171.181/32", "76.196.245.180/32"]
  }
}

resource "tls_private_key" "bastion_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "bastion_keypair" {
  key_name   = "last_stop_bastion_kp" # Create a "myKey" to AWS!!
  public_key = tls_private_key.bastion_private_key.public_key_openssh

  provisioner "local-exec" { # Create a "myKey.pem" to your computer!!
    command = "echo '${tls_private_key.bastion_private_key.private_key_pem}' > ./last_stop_bastion_kp.pem"
  }
}

resource "aws_instance" "bastion_instance" {
  ami           = data.aws_ami.amazon-linux-2.id # Replace with AMZ L2 AMI
  instance_type = "t2.micro"

  subnet_id = var.vpc_config.public_subnets[0] # pass in public subnet ID

  vpc_security_group_ids = [
    aws_security_group.bastion_sg.id
  ]

  key_name = aws_key_pair.bastion_keypair.name # generate a kp

  tags = {
    Name = "example-bastion-instance"
  }
}

resource "aws_eip" "bastion_eip" {
  instance = aws_instance.bastion_instance.id

  tags = {
    Name = "bastion_instance-eip"
  }
}

output "bastion_instance_public_ip" {
  description = "The public IP address of the bastion instance"
  value       = aws_eip.bastion_eip.public_ip
}