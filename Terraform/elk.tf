# ---------------------------------------------------------------------------------------------------------------------
# security group
# ---------------------------------------------------------------------------------------------------------------------
module "security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.17.0"

  name   = "${var.prefix_name}-elk"
  vpc_id = module.vpc_module.vpc_id

  ingress_cidr_blocks = ["10.0.2.0/24", "10.0.3.0/24", "10.0.5.0/24" ,"10.0.6.0/24"]
  ingress_rules = [
    "elasticsearch-rest-tcp",
    "elasticsearch-java-tcp",
    "kibana-tcp",
    "logstash-tcp",
    "ssh-tcp"
  ]
  ingress_with_self = [{ rule = "all-all" }]
  egress_rules      = ["all-all"]

}

# ---------------------------------------------------------------------------------------------------------------------
# ec2
# ---------------------------------------------------------------------------------------------------------------------
module "ec2-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.16.0"

  count                       = 1
  name                        = "${var.prefix_name}-elk"
  instance_type               = "t3.medium"
  ami                         = data.aws_ami.ubuntu-22.id
  key_name                    = aws_key_pair.kandula_key.key_name
  private_ip                  = "10.0.5.208"
  subnet_id                   = module.vpc_module.public_subnets_id[count.index]
  iam_instance_profile        = aws_iam_instance_profile.consul-join.name
  vpc_security_group_ids      = [module.security-group.this_security_group_id, aws_security_group.node_exporter_sg.id]
  associate_public_ip_address = true
  user_data = file("/home/isaac/test1/script/elk.sh")

  tags = {
    Terraform   = "true"
    Environment = "dev"
    consul_server = true
  }
}