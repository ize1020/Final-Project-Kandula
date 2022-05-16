resource "aws_security_group" "jenkins" {
  name = "jenkins_server_sg"
  description = "Allow Jenkins inbound traffic"
  vpc_id = module.vpc_module.vpc_id
  tags = {
    Name = "jenkins"
  }
}
resource "aws_security_group_rule" "jenkins_ssh" {
    description       = "allow ssh access from every"
    from_port         = 22
    protocol          = "tcp"
    security_group_id = aws_security_group.jenkins.id
    to_port           = 22
    type              = "ingress"
    cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "jenkins_8080_access" {
    description       = "allow 8080 access from anywhere"
    from_port         = 8080
    protocol          = "tcp"
    security_group_id = aws_security_group.jenkins.id
    to_port           = 8080
    type              = "ingress"
    source_security_group_id = aws_security_group.ALB_SG.id
}

resource "aws_security_group_rule" "jenkins_https_access" {
    description       = "allow https access from anywhere"
    from_port         = 443
    protocol          = "tcp"
    security_group_id = aws_security_group.jenkins.id
    to_port           = 443
    type              = "ingress"
    source_security_group_id = aws_security_group.ALB_SG.id
}
resource "aws_security_group_rule" "jenkins_server_anywhere" {
    description       = "allow outbound traffic to anywhere"
    from_port         = 0
    protocol           = "-1"
    security_group_id = aws_security_group.jenkins.id
    to_port           = 0
    type              = "egress"
    cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "all_consul_to_agent" {
  description              = "Allow all consul security group"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.jenkins.id
  to_port                  = 0
  type                     = "ingress"
  source_security_group_id = aws_security_group.consul_lb_sg.id
}
resource "aws_security_group_rule" "alb_jenkins" {
    description       = "Allow all alb security group"
    from_port         = 0
    protocol          = "-1"
    security_group_id = aws_security_group.jenkins.id
    to_port           = 0
    type              = "ingress"
    source_security_group_id = aws_security_group.ALB_SG.id

}
resource "aws_security_group_rule" "icmp_jenkins" {
    description       = "Allow ping"
    from_port   = 8
    protocol    = "icmp"
    security_group_id = aws_security_group.jenkins.id
    to_port           = 0
    type              = "ingress"
    cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "jenkins_inside_all" {
    description       = "Allow all inside security group"
    from_port         = 0
    protocol           = "-1"
    security_group_id = aws_security_group.jenkins.id
    to_port           = 0
    type              = "ingress"
    self              = true
}


resource "aws_instance" "jenkins_server" {
  count = 1

  ami = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  associate_public_ip_address = true

  subnet_id = module.vpc_module.public_subnets_id[count.index]
  iam_instance_profile        = aws_iam_instance_profile.consul-join.name
  vpc_security_group_ids = [aws_security_group.jenkins.id]
  key_name = aws_key_pair.kandula_key.key_name

  user_data = local.jenkins-master-userdate

  tags = {
    Name = "Jenkins Server"
    consul_agent = "true"
  }
}

resource "aws_instance" "jenkins_node" {
  count = 2

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"

  associate_public_ip_address = true

  subnet_id                   = module.vpc_module.private_subnets_id[count.index]
  iam_instance_profile        = aws_iam_instance_profile.eks-join.name
  private_ip                  = "${lookup(var.jenkins_node-private-ip,count.index)}"
  vpc_security_group_ids      = [aws_security_group.jenkins.id]
  depends_on                  = [aws_instance.jenkins_server]
  key_name                    = aws_key_pair.kandula_key.key_name

  user_data                   = local.jenkins_node-userdata

   tags = {
    Name          = "jenkins_node-${regex(".$", data.aws_availability_zones.available.names[count.index])}"
    consul_agent = "true"
  }
}

