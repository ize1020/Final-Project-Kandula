resource "aws_lb" "consul_lb" {
  count = 1
  name            = "consul-alb-${module.vpc_module.vpc_id}"
  subnets         = module.vpc_module.public_subnets_id
  security_groups = [aws_security_group.consul_lb_sg.id]
  load_balancer_type = "application"
  enable_cross_zone_load_balancing = true
  idle_timeout       = 65
   tags = {
    "Name" = "consul-alb-${module.vpc_module.vpc_id}"
  }
}
# sg_lb includes:
#   port 80 open to 0.0.0.0/0
#sg_consul servers
#      port 8500 to sg_lb

#sg_common
# 22 to sg_common
# 8300-8301 to sg_common

# Create a Listener
resource "aws_lb_listener" "consul-alb-listener" {
  count = 1
  default_action {
    target_group_arn = aws_lb_target_group.consul-target-group[0].arn
    type = "forward"
  }
  load_balancer_arn = aws_lb.consul_lb[0].arn
  port = 80
  protocol = "HTTP"
}


resource "aws_lb_target_group" "consul-target-group" {
  count = 1
  name = "consul-target-group"
  port = 8500
  protocol = "HTTP"
  vpc_id = module.vpc_module.vpc_id
  target_type = "instance"
  health_check {
    enabled = true
    path    = "/ui/"
  }
    tags = {
    "Name" = "consul-target-group-${module.vpc_module.vpc_id}"
  }
}

# restister targset to LB

resource "aws_lb_target_group_attachment" "consul_target_att" {
  count = 1
  target_group_arn = aws_lb_target_group.consul-target-group[0].arn
  target_id        = aws_instance.consul-Server[count.index].id
  port             = 8500

}





#alb to jenkins node

resource "aws_lb" "jenkins_lb" {
  count = 1
  name            = "jenkins-lb-${module.vpc_module.vpc_id}"
  subnets         = module.vpc_module.public_subnets_id
  security_groups = [aws_security_group.ALB_SG.id]
  load_balancer_type = "application"
  enable_cross_zone_load_balancing = true
  idle_timeout       = 65
   tags = {
    "Name" = "jenkins-lb-${module.vpc_module.vpc_id}"
  }
}

#listner for jenkins
resource "aws_lb_listener" "jenkins-alb-listener" {
  count = 1
  default_action {
    target_group_arn = aws_lb_target_group.jenkins-nodes[0].arn
    type = "forward"
  }
  load_balancer_arn = aws_lb.jenkins_lb[0].arn
  port = 80
  protocol = "HTTP"
}


resource "aws_lb_target_group" "jenkins-nodes" {
  count = 1
  name = "alb-jenkins-target-nodes"
  port = 8080
  protocol = "HTTP"
  vpc_id = module.vpc_module.vpc_id
  target_type = "instance"
  health_check {
   enabled = true
    path = "/"
  }
    tags = {
    "Name" = "alb-jenkins-target-nodes-${module.vpc_module.vpc_id}"
  }
}


#target group for jenkins 8080

resource "aws_alb_target_group_attachment" "jenkins_server" {
  count = 1
  target_group_arn = aws_lb_target_group.jenkins-nodes[0].arn
  target_id        = aws_instance.jenkins_node[count.index].id
  port             = 8080
}



#sg for ALB (consul and jenkins)

resource "aws_security_group" "ALB_SG" {
      name = "alb_security_group"
      vpc_id = module.vpc_module.vpc_id
      tags = {
          Name = "alb_security_group"
      }
}

resource "aws_security_group_rule" "alb_http_access" {
    description       = "allow http access from anywhere"
    from_port         = 80
    protocol          = "tcp"
    security_group_id = aws_security_group.ALB_SG.id
    to_port           = 80
    type              = "ingress"
    cidr_blocks       = ["${chomp(data.http.myip.body)}/32"]
}

resource "aws_security_group_rule" "alb_consul_ui_access" {
    description       = "Allow consul UI access from the world"
    from_port         = 8500
    protocol          = "tcp"
    security_group_id = aws_security_group.ALB_SG.id
    to_port           = 8500
    type              = "ingress"
    cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_jenkins_ui_access" {
    description       = "Allow consul UI access from the world"
    from_port         = 8080
    protocol          = "tcp"
    security_group_id = aws_security_group.ALB_SG.id
    to_port           = 8080
    type              = "ingress"
    cidr_blocks       = ["0.0.0.0/0"]

}

resource "aws_security_group_rule" "alb_inside_all" {
    description       = "Allow all inside security group"
    from_port         = 0
    protocol           = "-1"
    security_group_id = aws_security_group.ALB_SG.id
    to_port           = 0
    type              = "ingress"
    self              = true
}

resource "aws_security_group_rule" "alb_outbound_anywhere" {
    description       = "allow outbound traffic to anywhere"
    from_port         = 0
    protocol           = "-1"
    security_group_id = aws_security_group.ALB_SG.id
    to_port           = 0
    type              = "egress"
    cidr_blocks       = ["0.0.0.0/0"]
}