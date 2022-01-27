module myip {
  source  = "4ops/myip/http"
  version = "1.0.0"
}

locals {
  cidr_blocks_myip = format("%s/32", module.myip.address)
}

data "aws_ami" "latest_amzn2_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "block-device-mapping.volume-type"
    values = ["gp2"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_security_group" "remotedev_ec2_sg" {
  name        = "remotedev-ec2-sg"
  description = "EC2 Security Group"
  vpc_id      = aws_vpc.remotedev_vpc.id

  tags = {
    Name = "remotedev-ec2-sg"
  }
}

resource "aws_security_group_rule" "remotedev_ec2_in_ssh" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = (var.cidr_blocks_ssh_in == null)? [local.cidr_blocks_myip] : [var.cidr_blocks_ssh_in]
  security_group_id = aws_security_group.remotedev_ec2_sg.id
  description       = "incoming rule for SSH"

}

resource "aws_security_group_rule" "remotedev_ec2_out" {
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"] #tfsec:ignore:AWS007
  security_group_id = aws_security_group.remotedev_ec2_sg.id
  description       = "allow all outgoing communication"
}

resource "aws_key_pair" "remotedev_keypair" {
  public_key = file(var.ssh_public_key_file_path)
}

resource "aws_instance" "remotedev_ec2" {
  instance_type          = var.aws_instance_type
  ami                    = data.aws_ami.latest_amzn2_linux.image_id
  subnet_id              = aws_subnet.remotedev_subnet_a.id
  key_name               = aws_key_pair.remotedev_keypair.id
  iam_instance_profile   = aws_iam_instance_profile.remotedev_cloudwatch_agent_aim_profile.name
  vpc_security_group_ids = [
    aws_security_group.remotedev_ec2_sg.id,
  ]
  user_data              = file(var.cloud_init_script_path)
  root_block_device {
    volume_type = var.aws_root_volume_type
    volume_size = var.aws_root_volume_size
  }
  tags = {
    Name = "remotedev-ec2"
  }
  metadata_options {
    http_endpoint = "enabled"
  }
}