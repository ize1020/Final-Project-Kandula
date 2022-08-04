#Create security group for database servers
resource "aws_security_group" "consul" {
  name = "consul"
  description = "security group for databases"
  vpc_id = module.vpc_module.vpc_id
}

resource "aws_security_group" "consul_server_sg" {
  name        = "consul-server-sg"
  description = "Allow consul ui"
  vpc_id      = module.vpc_module.vpc_id
  tags = {
    Name = format("%s-consul-server-sg", var.global_name_prefix)
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "consul_ui" {
  type              = "ingress"
  from_port         = 8500
  to_port           = 8500
  protocol          = "tcp"
  cidr_blocks       = ["10.0.2.0/24", "10.0.3.0/24", "10.0.5.0/24" ,"10.0.6.0/24"]
  description       = "Allow consul UI access from vpc"
  security_group_id = aws_security_group.consul_server_sg.id
}

resource "aws_security_group_rule" "consul_serf_tcp" {
  type              = "ingress"
  from_port         = 8300
  to_port           = 8302
  protocol          = "tcp"
  self              = true
  description       = "Allow serf ports tcp"
  security_group_id = aws_security_group.consul.id
}

resource "aws_security_group_rule" "consul_serf_udp" {
  type              = "ingress"
  from_port         = 8300
  to_port           = 8302
  protocol          = "udp"
  self              = true
  description       = "Allow serf ports udp"
  security_group_id = aws_security_group.consul.id
}

resource "aws_security_group_rule" "consul_dns_tcp" {
  type              = "ingress"
  from_port         = 8600
  to_port           = 8600
  protocol          = "tcp"
  self              = true
  description       = "Allow serf ports udp"
  security_group_id = aws_security_group.consul.id
}

resource "aws_security_group_rule" "consul_dns_udp" {
  type              = "ingress"
  from_port         = 8600
  to_port           = 8600
  protocol          = "udp"
  self              = true
  description       = "Allow serf ports udp"
  security_group_id = aws_security_group.consul.id
}

resource "aws_security_group_rule" "ssh_c" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  self              = true
  description       = "Allow ssh from the world"
  security_group_id = aws_security_group.consul.id
}

resource "aws_security_group_rule" "out_c" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outside security group"
  security_group_id = aws_security_group.consul.id

}
resource "aws_security_group_rule" "ping_c" {
  type              = "ingress"
  from_port         = 8
  to_port           = 0
  protocol          = "icmp"
  self              = true
  description       = "Allow ping"
  security_group_id = aws_security_group.consul.id
}

resource "aws_security_group_rule" "ssh_inside_c" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["10.0.2.0/24", "10.0.3.0/24", "10.0.5.0/24" ,"10.0.6.0/24"]
  description       = "Allow ssh_inside vpc"
  security_group_id = aws_security_group.consul.id
}