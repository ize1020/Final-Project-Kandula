resource "aws_security_group" "jenkins" {
  name = "jenkins"
  description = "Allow Jenkins inbound traffic"
  vpc_id      = module.vpc_module.vpc_id
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  dynamic "ingress" {
    iterator = port
    for_each = var.ingress_ports
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    description = "Allow all outgoing traffic"
    from_port = 0
    to_port = 0
    // -1 means all
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name = "jenkins"
  }
}

resource "aws_instance" "jenkins_server" {
  count = 1

  ami = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  associate_public_ip_address = true

  subnet_id = module.vpc_module.public_subnets_id[count.index]

  vpc_security_group_ids = [aws_security_group.jenkins.id]
  key_name = aws_key_pair.kandula_key.key_name

  user_data = local.jenkins-master-userdate

  tags = {
    Name = "Jenkins Server"
  }
}