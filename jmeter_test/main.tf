# * Part 1 - Setup.
locals {
	container_name = "jmeter-test-container"
	# container_port = 8080 # ! Must be same port from our Dockerfile that we EXPOSE
	example = "example-ecs-terraform-aws-modules"
}

provider "aws" {
	region = "us-east-1"

	default_tags {
		tags = { example = jmeter }
	}
}

# * Give Docker permission to pusher Docker Images to AWS.
data "aws_caller_identity" "this" {}
data "aws_ecr_authorization_token" "this" {}
data "aws_region" "this" {}
locals { ecr_address = format("%v.dkr.ecr.%v.amazonaws.com", data.aws_caller_identity.this.account_id, data.aws_region.this.name) }
provider "docker" {
	registry_auth {
		address  = local.ecr_address
		password = data.aws_ecr_authorization_token.this.password
		username = data.aws_ecr_authorization_token.this.user_name
	}
}

# * Part 2 - Build and push Docker image.
module "ecr" {
	source  = "terraform-aws-modules/ecr/aws"
	version = "~> 1.6.0"

	repository_force_delete = true
	repository_name = local.example
	repository_lifecycle_policy = jsonencode({
		rules = [{
			action = { type = "expire" }
			description = "Delete all images except a handful of the newest images"
			rulePriority = 1
			selection = {
				countNumber = 3
				countType = "imageCountMoreThan"
				tagStatus = "any"
			}
		}]
	})
}

# * Build our Image locally with the appropriate name to push our Image
# * to our Repository in AWS.
resource "docker_image" "this" {
	name = format("%v:%v", module.ecr.repository_url, formatdate("YYYY-MM-DD'T'hh-mm-ss", timestamp()))

	build { context = "." }
}

# * Push our Image to our Repository.
resource "docker_registry_image" "this" {
	keep_remotely = true # Do not delete the old image when a new image is built
	name = resource.docker_image.this.name
}

# * Part 3 - Create VPC
data "aws_availability_zones" "available" { state = "available" }
module "vpc" {
	source = "terraform-aws-modules/vpc/aws"
	version = "~> 3.19.0"

	azs = slice(data.aws_availability_zones.available.names, 0, 2) # Span subnetworks across multiple avalibility zones
	cidr = "10.0.0.0/16"
	create_igw = true # Expose public subnetworks to the Internet
	enable_nat_gateway = true # Hide private subnetworks behind NAT Gateway
	private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
	public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
	single_nat_gateway = true
}

# * Step 5 - Create our ECS Cluster.
module "ecs" {
	source  = "terraform-aws-modules/ecs/aws"
	version = "~> 4.1.3"

	cluster_name = local.example

	# * Allocate 20% capacity to FARGATE and then split
	# * the remaining 80% capacity 50/50 between FARGATE
	# * and FARGATE_SPOT.
	fargate_capacity_providers = {
		FARGATE = {
			default_capacity_provider_strategy = {
				base   = 20
				weight = 50
			}
		}
		FARGATE_SPOT = {
			default_capacity_provider_strategy = {
				weight = 50
			}
		}
	}
}

# * Step 6 - Create our ECS Task Definition
data "aws_iam_policy_document" "this" {
	version = "2012-10-17"

	statement {
		actions = ["sts:AssumeRole"]
		effect = "Allow"

		principals {
			identifiers = ["ecs-tasks.amazonaws.com"]
			type = "Service"
		}
	}
}
resource "aws_iam_role" "this" { assume_role_policy = data.aws_iam_policy_document.this.json }
resource "aws_iam_role_policy_attachment" "this" {
	policy_arn  = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
	role = resource.aws_iam_role.this.name
}
resource "aws_ecs_task_definition" "this" {
	container_definitions = jsonencode([{
		environment: [
			{ name = "MY_INPUT_ENV_VAR", value = "terraform-modified-env-var" }
		],
		essential = true,
		image = resource.docker_registry_image.this.name,
		name = local.container_name,
		portMappings = [{ containerPort = local.container_port }],
	}])
	cpu = 256
	execution_role_arn = resource.aws_iam_role.this.arn
	family = "family-of-${local.example}-tasks"
	memory = 512
	network_mode = "awsvpc"
	requires_compatibilities = ["FARGATE"]
}

# * Step 7 - Run our application.
resource "aws_ecs_service" "this" {
	cluster = module.ecs.cluster_id
	desired_count = 1
	launch_type = "FARGATE"
	name = "${local.example}-service"
	task_definition = resource.aws_ecs_task_definition.this.arn

	lifecycle {
		ignore_changes = [desired_count] # Allow external changes to happen without Terraform conflicts, particularly around auto-scaling.
	}

	load_balancer {
		container_name = local.container_name
		container_port = local.container_port
		target_group_arn = module.alb.target_group_arns[0]
	}

	network_configuration {
		security_groups = [module.vpc.default_security_group_id]
		subnets = module.vpc.private_subnets
	}
}

# * Step 8 - See our application working.
# * Output the URL of our Application Load Balancer so that we can connect to
# * our application running inside  ECS once it is up and running.
output "lb_url" { value = "http://${module.alb.lb_dns_name}" }
