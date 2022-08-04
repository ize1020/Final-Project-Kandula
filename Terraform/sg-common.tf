resource "aws_security_group" "common" {
  name        = "common-sg"
  description = "Allow ssh, ping and egress traffic"
  vpc_id      = module.vpc_module.vpc_id
  tags = {
    Name = format("%s-common-sg", var.global_name_prefix)
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  self              = true
  description       = "Allow ssh from the world"
  security_group_id = aws_security_group.common.id
}

resource "aws_security_group_rule" "out" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outside security group"
  security_group_id = aws_security_group.common.id

}
resource "aws_security_group_rule" "ping" {
  type              = "ingress"
  from_port         = 8
  to_port           = 0
  protocol          = "icmp"
  self              = true
  description       = "Allow ping"
  security_group_id = aws_security_group.common.id
}

resource "aws_security_group_rule" "ssh_inside" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["10.0.2.0/24", "10.0.3.0/24", "10.0.5.0/24" ,"10.0.6.0/24"]
  description       = "Allow ssh_inside vpc"
  security_group_id = aws_security_group.common.id
}

resource "aws_security_group_rule" "filebeat_inside" {
  type              = "ingress"
  from_port         = 9200
  to_port           = 9200
  protocol          = "tcp"
  cidr_blocks       = ["10.0.2.0/24", "10.0.3.0/24", "10.0.5.0/24" ,"10.0.6.0/24"]
  description       = "Allow filebeat_inside vpc"
  security_group_id = aws_security_group.common.id
}

resource "aws_security_group_rule" "filebeat_outside" {
  type              = "egress"
  from_port         = 9200
  to_port           = 9200
  protocol          = "tcp"
  cidr_blocks       = ["10.0.2.0/24", "10.0.3.0/24", "10.0.5.0/24" ,"10.0.6.0/24"]
  description       = "Allow filebeat_outside vpc"
  security_group_id = aws_security_group.common.id
}

resource "aws_security_group_rule" "kibana_inside" {
  type              = "ingress"
  from_port         = 5601
  to_port           = 5601
  protocol          = "tcp"
  cidr_blocks       = ["10.0.2.0/24", "10.0.3.0/24", "10.0.5.0/24" ,"10.0.6.0/24"]
  description       = "Allow kibana_inside vpc"
  security_group_id = aws_security_group.common.id
}

resource "aws_security_group_rule" "kibana_outside" {
  type              = "egress"
  from_port         = 5601
  to_port           = 5601
  protocol          = "tcp"
  cidr_blocks       = ["10.0.2.0/24", "10.0.3.0/24", "10.0.5.0/24" ,"10.0.6.0/24"]
  description       = "Allow kibana_outside vpc"
  security_group_id = aws_security_group.common.id
}
