
#
## define the service to run on the created ECS cluster
#

resource "aws_ecs_service" "houly-ecs-service" {
  	name            = "houly-ecs-service"
  	iam_role        = "${aws_iam_role.ecs-service-role.name}"
  	cluster         = "${aws_ecs_cluster.houly-ecs-cluster.id}"
  	task_definition = "${aws_ecs_task_definition.wordpress.family}:${max("${aws_ecs_task_definition.wordpress.revision}", "${data.aws_ecs_task_definition.wordpress.revision}")}"
  	desired_count   = 2

  	load_balancer {
    	target_group_arn  = "${aws_alb_target_group.houly-ecs-target-group.arn}"
    	container_port    = 80
    	container_name    = "wordpress"
	}
}
