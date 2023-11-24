resource "aws_iam_role" "Vivek_role" {
  name = "Jenkins-terraform1"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "Vivek_attachment" {
  role       = aws_iam_role.Vivek_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "Vivek_profile" {
  name = "Jenkins-terraform1"
  role = aws_iam_role.Vivek_role.name
}


resource "aws_security_group" "Jenkins1-sg" {
  name        = "Jenkins1-Security Group"
  description = "Open 22,443,80,8080,9000"

  # Define a single ingress rule to allow traffic on all specified ports
  ingress = [
    for port in [22, 80, 443, 8080, 9000, 3000] : {
      description      = "TLS from VPC"
      from_port        = port
      to_port          = port
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Jenkins1-sg"
  }
}

resource "aws_instance" "jenkins1" {
  ami                    = "ami-0f5ee92e2d63afc18"
  instance_type          = "t2.large"
  key_name               = "VivekKey"
  vpc_security_group_ids = [aws_security_group.Jenkins1-sg.id]
  user_data              = templatefile("./install_jenkins.sh", {})
  iam_instance_profile   = aws_iam_instance_profile.Vivek_profile.name

  tags = {
    Name = "Jenkins-Argo123"
  }

  root_block_device {
    volume_size = 30
  }
}

resource "aws_eip" "jenkins1" {
  instance = aws_instance.jenkins1.id
  domain   = "vpc"

  tags = {
    Name = "Jenkins1-EIP"
  }
}
