houly#
## includes the tf code responsible for deploying the ALB, ASG and launch config
#

## Remote state import for VPC

data "terraform_remote_state" "environment" {
  backend = "s3"
  config {
    bucket = "houly-remote-state"
    key = "aws/dev/environment/vpc.tfstate"
    region = "${var.region}"
  }
}

## Launch config

resource "aws_launch_configuration" "houly-ecs-LC" {
    name                        = "houly-ecs-LC"
    image_id                    = "var.image_id"
    instance_type               = "t2.xlarge"
    iam_instance_profile        = "${aws_iam_instance_profile.houly-ecs-inst-profile.id}"

    root_block_device {
      volume_type = "standard"
      volume_size = 100
      delete_on_termination = true
    }

    lifecycle {
      create_before_destroy = true
    }

    security_groups             = ["${aws_security_group.houly_public_sg.id}"]
    associate_public_ip_address = "true"
    key_name                    = "${var.ecs_key_pair_name}"
    user_data                   = <<EOF
                                  #!/bin/bash
                                  echo ECS_CLUSTER=${var.houly_ecs_cluster} >> /etc/ecs/ecs.config
                                  EOF
}

## AutoScaling Group

resource "aws_autoscaling_group" "houly_ecs-ASG" {
    name                        = "houly_ecs-ASG"
    max_size                    = "${var.max_instance_size}"
    min_size                    = "${var.min_instance_size}"
    desired_capacity            = "${var.desired_capacity}"
    vpc_zone_identifier         = ["${data.terraform_remote_state.environment.houly_public_sn_01.id}", "${data.terraform_remote_state.environment.houly_public_sn_02.id}"]
    launch_configuration        = "${aws_launch_configuration.houly-ecs-LC.name}"
    health_check_type           = "ELB"
  }

## ALB config

resource "aws_alb" "houly-ecs-LB" {
    name                = "houly-ecs-LB"
    security_groups     = ["${aws_security_group.houly_public_sg.id}"]
    subnets             = ["${data.terraform_remote_state.environment.houly_public_sn_01.id}", "${data.terraform_remote_state.environment.houly_public_sn_02.id}"]

    tags {
      Name = "houly-ecs-LB"
    }
}

resource "aws_alb_target_group" "houly-ecs-target-group" {
    name                = "houly-ecs-target-group"
    port                = "80"
    protocol            = "HTTP"
    vpc_id              = "${data.terraform_remote_state.environment.houly_vpc.id}"

    health_check {
        healthy_threshold   = "5"
        unhealthy_threshold = "2"
        interval            = "30"
        matcher             = "200"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = "5"
    }

    tags {
      Name = "houly-ecs-target-group"
    }
}

resource "aws_alb_listener" "houly-alb-listener" {
    load_balancer_arn = "${aws_alb.houly-ecs-LB.arn}"
    port              = "80"
    protocol          = "HTTP"

    default_action {
        target_group_arn = "${aws_alb_target_group.houly-ecs-target-group.arn}"
        type             = "forward"
    }
}

## ECS cluster

resource "aws_ecs_cluster" "houly-ecs-cluster" {
    name = "${var.houly_ecs_cluster}"
}
