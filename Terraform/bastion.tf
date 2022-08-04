#bastion-ansible server

resource "aws_instance" "Bastion-ansible" {
  count =1 
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = module.vpc_module.public_subnets_id[count.index]
  iam_instance_profile        = aws_iam_instance_profile.consul-join.name
  vpc_security_group_ids      = [aws_security_group.bastion-ansible.id]
  key_name                    = aws_key_pair.kandula_key.key_name
  user_data = local.bastion-userdata
  tags = {
    Name = "Bastion-ansible"
  }
}

#Security Group for bastion-ansible server

resource "aws_security_group" "bastion-ansible" {
 name        = "bastion-ansible"
 description = "security group for bastion-ansible servers"
 vpc_id      = module.vpc_module.vpc_id
  egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
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
  ingress {
   from_port   = 8
   to_port     = 0
   protocol    = "icmp"
   cidr_blocks = ["0.0.0.0/0"]
 }
}