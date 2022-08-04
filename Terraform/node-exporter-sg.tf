resource "aws_security_group" "node_exporter_sg" {
  name        = "node-exporter-sg"
  description = "Security group for node-exporter"
  vpc_id      = module.vpc_module.vpc_id
  tags = {
    Name = format("%s-node-exporter-sg", var.global_name_prefix)
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "node_exporter" {
  type              = "ingress"
  from_port         = 9100
  to_port           = 9100
  protocol          = "tcp"
  cidr_blocks      = ["10.0.2.0/24", "10.0.3.0/24", "10.0.5.0/24" ,"10.0.6.0/24"]
  description       = "Allow node_exporter port within group"
  security_group_id = aws_security_group.node_exporter_sg.id
}

resource "aws_security_group_rule" "node_exporter_out" {
  type              = "egress"
  from_port         = 9100
  to_port           = 9100
  protocol          = "-1"
  cidr_blocks      = ["10.0.2.0/24", "10.0.3.0/24", "10.0.5.0/24" ,"10.0.6.0/24"]
  description       = "Allow node_exporter port within group"
  security_group_id = aws_security_group.node_exporter_sg.id
}