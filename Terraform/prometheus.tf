resource "aws_instance" "prometheus" {
  count                       = 1
  ami                         = data.aws_ami.ubuntu-22.id
  instance_type               = "t3.micro"
  subnet_id                   = element(module.vpc_module.private_subnets_id, count.index)
  private_ip                  = "10.0.2.85"
  key_name                    = aws_key_pair.kandula_key.key_name
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.consul-join.name
  user_data = file("/home/isaac/test1/script/elk.sh")
  
  vpc_security_group_ids      = [ 
    aws_security_group.consul.id,
    aws_security_group.common.id,
    aws_security_group.prometheus_sg.id,
    aws_security_group.node_exporter_sg.id
  ]


  metadata_options {
    http_endpoint          = "enabled"
    http_tokens            = "optional"
    instance_metadata_tags = "enabled"
  }

  tags = {
    Name                = format("%s-prometheus-server-${count.index}", var.global_name_prefix)
    consul_server = true
    is_service_instance = true
  }
}


resource "aws_security_group" "prometheus_sg" {
  name        = "prometheus-sg"
  description = "Security group for prometheus server"
  vpc_id      = module.vpc_module.vpc_id
  tags = {
    Name = format("%s-prometheus-sg", var.global_name_prefix)
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "prometheus_grafana" {
  type              = "ingress"
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
  cidr_blocks       = ["10.0.2.0/24", "10.0.3.0/24", "10.0.5.0/24" ,"10.0.6.0/24"]
  description       = "Allow grafana ui from vpc"
  security_group_id = aws_security_group.prometheus_sg.id
}

resource "aws_security_group_rule" "prometheus_ui" {
  type              = "ingress"
  from_port         = 9090
  to_port           = 9090
  protocol          = "tcp"
  cidr_blocks       = ["10.0.2.0/24", "10.0.3.0/24", "10.0.5.0/24" ,"10.0.6.0/24"]
  description       = "Allow prometheus ui from vpc"
  security_group_id = aws_security_group.prometheus_sg.id
}
