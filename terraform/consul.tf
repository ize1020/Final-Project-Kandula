#Create security group for database servers
resource "aws_security_group" "consul" {
  name = "consul"
  description = "security group for databases"
  vpc_id = module.vpc_module.vpc_id
}
# TODO: move to VPC common sg
resource "aws_security_group" "common" {
  name = "common"
  description = "security group for all servers"
  vpc_id = module.vpc_module.vpc_id
}
resource "aws_security_group" "consul_lb_sg" {
  name = "consul_lb_sg"
  description = "security group for load balancers of consul"
  vpc_id = module.vpc_module.vpc_id
}

resource "aws_security_group_rule" "ui_access" {
    from_port   = 8500
    to_port     = 8500
    protocol = "tcp"
    type= "ingress"
    security_group_id = aws_security_group.consul.id
    source_security_group_id = aws_security_group.consul_lb_sg.id
    description = "Allow ui port"
}
resource "aws_security_group_rule" "ui_access_out" {
    from_port   = 8500
    to_port     = 8500
    protocol = "tcp"
    type= "egress"
    security_group_id = aws_security_group.consul_lb_sg.id
    self = true
    description = "open ui out port"
}
resource "aws_security_group_rule" "ui_access-8600" {
    from_port   = 8600
    to_port     = 8600
    protocol = "tcp"
    type= "ingress"
    security_group_id = aws_security_group.consul.id
    source_security_group_id = aws_security_group.consul_lb_sg.id
    description = "Allow ui port"
}
resource "aws_security_group_rule" "ui_access_out-8600" {
    from_port   = 8600
    to_port     = 8600
    protocol = "tcp"
    type= "egress"
    security_group_id = aws_security_group.consul_lb_sg.id
    self = true
    description = "open ui out port"
}
resource "aws_security_group_rule" "consul_internal_access" {
    from_port   = 8300
    to_port     = 8301
    protocol = -1
    type= "ingress"
    security_group_id = aws_security_group.common.id
    self = true
    description = "Allow internal consul ports"
}

resource "aws_security_group_rule" "consul_ping1" {
    from_port   = 8
    to_port     = 0
    protocol = "icmp"
    type= "ingress"
    security_group_id = aws_security_group.consul.id
#    self = true
    cidr_blocks = ["10.0.2.0/24", "10.0.3.0/24", "10.0.5.0/24" ,"10.0.6.0/24"]
    description = "Allow ping "
}
resource "aws_security_group_rule" "consul_ssh_access1" {
    from_port   = 22
    to_port     = 22
    protocol = "tcp"
    type= "ingress"
    security_group_id = aws_security_group.consul.id
#    self = true
    cidr_blocks = ["10.0.2.0/24", "10.0.3.0/24", "10.0.5.0/24" ,"10.0.6.0/24"]
    description = "Allow ssh access in vpc"
}

resource "aws_security_group_rule" "consul_out" {
    from_port   = 0
    to_port     = 0
    protocol = "-1"
    type= "egress"
    security_group_id = aws_security_group.common.id
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow access out "
}

resource "aws_security_group_rule" "lb_incomming" {
    from_port   = 80
    to_port     = 80
    protocol = "tcp"
    type= "ingress"
    security_group_id = aws_security_group.consul_lb_sg.id
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow access out "
}

resource "aws_instance" "consul-Server" {
  count = 3
  ami                         = data.aws_ami.ubuntu-21.id
  key_name                    = aws_key_pair.kandula_key.key_name
  instance_type               = "t3.micro"
  associate_public_ip_address = false
  vpc_security_group_ids      = [ aws_security_group.consul.id , aws_security_group.common.id ,aws_security_group.consul_lb_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.consul-join.name
  subnet_id                   = element(module.vpc_module.private_subnets_id, count.index)
  private_ip                  = "${lookup(var.ips,count.index)}"
#  user_data                   = local.consul_server-userdata
  tags = {
    Name          = "consul-Server-${regex(".$", data.aws_availability_zones.available.names[count.index])}"
    consul_server = "true"
  }
}


resource "aws_instance" "consul-agent" {
  count = 1
  ami                         = data.aws_ami.ubuntu-21.id
  key_name                    = aws_key_pair.kandula_key.key_name
  instance_type               = "t3.micro"
  associate_public_ip_address = false
  vpc_security_group_ids      = [ aws_security_group.consul.id , aws_security_group.common.id ,aws_security_group.consul_lb_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.consul-join.name
  subnet_id                   = module.vpc_module.private_subnets_id[count.index]
  private_ip                  = "10.0.2.20"
#  user_data                   = local.consul_agent-userdata

  tags = {
    Name         = "consul-agent-${regex(".$", data.aws_availability_zones.available.names[count.index])}"
    consul_agent = "true"
    subnet        = element(module.vpc_module.private_subnets_id, count.index)
  }
}

# Create an IAM role for the auto-join
resource "aws_iam_role" "consul-join" {
  name               = "consul-join"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

}

# Create the policy
resource "aws_iam_policy" "consul-join" {
  name        = "consul-join"
  description = "Allows Consul nodes to describe instances for joining."
  policy      = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:DescribeInstances",
      "Resource": "*"
    }
  ]
})
}

# Attach the policy
resource "aws_iam_policy_attachment" "consul-join" {
  name       = "consul-join"
  roles      = [aws_iam_role.consul-join.name]
  policy_arn = aws_iam_policy.consul-join.arn
}

# Create the instance profile
resource "aws_iam_instance_profile" "consul-join" {
  name = "consul-join"
  role = aws_iam_role.consul-join.name
}


output "consul-join-iam-role" {
  description = "arn for consul-join iam role"
  value       = aws_iam_role.consul-join.arn
}

