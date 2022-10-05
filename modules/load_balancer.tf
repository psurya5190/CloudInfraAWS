/*** A security group to allow SSH access into our load balancer*/ resource "aws_security_group" "lb" {
  name   = "ecs-alb-security-group"
  vpc_id = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-lb-sg"
  }
}

/***Load Balancer to be attached to the ECS cluster to distribute the load among instances*/
/*
 resource "aws_elb" "jenkins_elb" { 
  subnets    = [for subnet in aws_subnet.public_subnets : subnet.id]
    cross_zone_load_balancing = true 
    security_groups       = [aws_security_group.lb.id] 
    instances             = [aws_instance.jenkins_master.id] 
    
    listener { 
      instance_port     = 8080 
        instance_protocol = "http" 
        lb_port           = 80 
        lb_protocol       = "http" 
     } 
     
     health_check { 
      healthy_threshold   = 2 
        unhealthy_threshold = 2 
        timeout             = 3 
        target              = "TCP:8080"    
        interval            = 5 
    } 
    
    tags = { 
      Name = "jenkins_elb" 
    } 
 }
*/

resource "aws_lb" "jenkins_elb" {
  name               = "jenkins-elb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  subnets            = [for subnet in aws_subnet.public_subnets : subnet.id]
/*
  enable_deletion_protection = true
  
    listener { 
      instance_port     = 80 
        instance_protocol = "http" 
        lb_port           = 80 
        lb_protocol       = "http" 
     } 
     
     health_check { 
      healthy_threshold   = 2 
        unhealthy_threshold = 2 
        timeout             = 3 
        target              = "TCP:80"    
        interval            = 5 
    }
    */

  tags = {
    Name = "jenkins_elb"
  }
}


resource "aws_lb_target_group" "jenkin_elb_tg" {
  name     = "jenkin-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group_attachment" "jenkin_elb_tg_attach" {
  target_group_arn = aws_lb_target_group.jenkin_elb_tg.arn
  target_id        = aws_instance.jenkins_master.id
  port             = 80
}

resource "aws_lb_listener" "elb_target_to_tg" {
  load_balancer_arn = aws_lb.jenkins_elb.arn
  port              = "80"
  protocol          = "HTTP"
  #  ssl_policy        = "ELBSecurityPolicy-2016-08"
  #  certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkin_elb_tg.arn
  }
}

output "load-balancer-ip" {
  value = aws_lb.jenkins_elb.dns_name
}