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



