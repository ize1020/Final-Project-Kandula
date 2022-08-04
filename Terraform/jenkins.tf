resource "aws_instance" "jenkins_server" {
  count = 1

  ami = "ami-0f47372bb64d6f5cd"
  instance_type = "t3.micro"
  associate_public_ip_address = false
  subnet_id                   = module.vpc_module.private_subnets_id[count.index]
  iam_instance_profile        = aws_iam_instance_profile.jenkins.name
  private_ip                  = "10.0.2.30"
  
  vpc_security_group_ids      = [
    aws_security_group.jenkins_sg.id,
    aws_security_group.common.id,
    aws_security_group.consul.id,
    aws_security_group.node_exporter_sg.id
  ]

  metadata_options {
    http_endpoint          = "enabled"
    http_tokens            = "optional"
    instance_metadata_tags = "enabled"
  }

  key_name                    = aws_key_pair.kandula_key.key_name
  
  tags = {
    Name          = "Jenkins Server"
    consul_server = true
  }
}


resource "aws_instance" "jenkins_node" {
  count = 2

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"

  associate_public_ip_address = true

  subnet_id                   = module.vpc_module.private_subnets_id[count.index]
  iam_instance_profile        = aws_iam_instance_profile.eks.name
  private_ip                  = "${lookup(var.jenkins_node-private-ip,count.index)}"

  vpc_security_group_ids      = [
    aws_security_group.jenkins_sg.id,
    aws_security_group.common.id,
    aws_security_group.consul.id,
    aws_security_group.node_exporter_sg.id
  ]
  
  metadata_options {
    http_endpoint          = "enabled"
    http_tokens            = "optional"
    instance_metadata_tags = "enabled"
  }

  depends_on                  = [aws_instance.jenkins_server]
  key_name                    = aws_key_pair.kandula_key.key_name
  user_data                   = local.jenkins_node-userdata

   tags = {
    Name         = "jenkins_node-${regex(".$", data.aws_availability_zones.available.names[count.index])}"
    consul_server = true
  }
}


resource "aws_security_group" "jenkins_sg" {
  name = "jenkins_server_sg"
  description = "Allow Jenkins inbound traffic"
  vpc_id = module.vpc_module.vpc_id
  tags = {
    Name = "jenkins_sg"
  }
}

resource "aws_security_group_rule" "jenkins_https_all" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks = ["10.0.2.0/24", "10.0.3.0/24", "10.0.5.0/24" ,"10.0.6.0/24"]
  security_group_id = aws_security_group.jenkins_sg.id
}

resource "aws_security_group_rule" "jenkins_ui_all" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks = ["10.0.2.0/24", "10.0.3.0/24", "10.0.5.0/24" ,"10.0.6.0/24"]
  security_group_id = aws_security_group.jenkins_sg.id
}
