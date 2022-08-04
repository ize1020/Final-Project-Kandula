resource "aws_instance" "consul-Server" {
  count = 3
  ami                         = data.aws_ami.ubuntu-22.id
  key_name                    = aws_key_pair.kandula_key.key_name
  instance_type               = "t3.micro"
  associate_public_ip_address = false

  vpc_security_group_ids      = [ 
    aws_security_group.consul.id,
    aws_security_group.consul_server_sg.id,
    aws_security_group.common.id,
    aws_security_group.node_exporter_sg.id
  ]

  iam_instance_profile        = aws_iam_instance_profile.consul-join.name
  subnet_id                   = element(module.vpc_module.private_subnets_id, count.index)
  private_ip                  = "${lookup(var.consul-private-ip,count.index)}"
#  user_data                   = local.consul_server-userdata
  tags = {
    Name          = "consul-Server-${regex(".$", data.aws_availability_zones.available.names[count.index])}"
    consul_server = "true"
  }
}


resource "aws_instance" "consul-agent" {
  count = 1
  ami                         = data.aws_ami.ubuntu-22.id
  key_name                    = aws_key_pair.kandula_key.key_name
  instance_type               = "t3.micro"
  associate_public_ip_address = false

  vpc_security_group_ids      = [ 
    aws_security_group.consul.id, 
    aws_security_group.consul_server_sg.id,
    aws_security_group.common.id,
    aws_security_group.node_exporter_sg.id
  ]

  iam_instance_profile        = aws_iam_instance_profile.consul-join.name
  subnet_id                   = module.vpc_module.private_subnets_id[count.index]
  private_ip                  = "10.0.2.20"
  user_data                   = local.consul_agent-userdata

  tags = {
    Name         = "consul-agent-${regex(".$", data.aws_availability_zones.available.names[count.index])}"
    consul_agent = "true"
    subnet        = element(module.vpc_module.private_subnets_id, count.index)
  }
}
