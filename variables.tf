variable "environment" {
  type        = string
  description = "The name of the environment"
}

variable "tags" {
  description = "A map of tags to use on all resources"
  type        = map(string)
}

variable "name" {
  description = "Name to use on all resources created (VPC, ALB, etc)"
  type        = string
  default     = "app"
}

variable "internal" {
  description = "Whether the load balancer is internal or external"
  type        = bool
  default     = false
}

variable "app_fqdn" {
  description = "FQDN of app to use. Set this only to override Route53 and ALB's DNS name."
  type        = string
  default     = null
}

# VPC
variable "vpc_id" {
  description = "ID of an existing VPC where resources will be created"
  type        = string
  default     = ""
}

variable "public_subnet_ids" {
  description = "A list of IDs of existing public subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "private_subnet_ids" {
  description = "A list of IDs of existing private subnets inside the VPC"
  type        = list(string)
  default     = []
}

# ALB
variable "alb_ingress_cidr_blocks" {
  description = "Comma separated string of IPv4 CIDR ranges to use on all ingress rules of the ALB."
  type        = string
  default     = "0.0.0.0/0"
}

variable "alb_log_bucket_name" {
  description = "S3 bucket (externally created) for storing load balancer access logs. Required if alb_logging_enabled is true."
  type        = string
  default     = ""
}

variable "alb_log_location_prefix" {
  description = "S3 prefix within the log_bucket_name under which logs are stored."
  type        = string
  default     = ""
}

variable "alb_logging_enabled" {
  description = "Controls if the ALB will log requests to S3."
  type        = bool
  default     = false
}

# ACM
variable "certificate_arn" {
  description = "ARN of certificate issued by AWS ACM. If empty, a new ACM certificate will be created and validated using Route53 DNS"
  type        = string
}

# Route53
variable "route53_zone_name" {
  description = "Route53 zone name to create ACM certificate in and main A-record, without trailing dot"
  type        = string
}

variable "route53_record_name" {
  description = "Name of Route53 record to create ACM certificate in and main A-record. If null is specified, var.name is used instead. Provide empty string to point root domain name to ALB."
  type        = string
  default     = null
}

variable "create_route53_record" {
  description = "Whether to create Route53 record for app"
  type        = bool
  default     = true
}

# Cloudwatch
variable "cloudwatch_log_retention_in_days" {
  description = "Retention period of app CloudWatch logs"
  type        = number
  default     = 7
}

# ECS Service / Task
variable "ecs_cluster_id" {
  description = "The ECS cluster ID"
}

variable "ecs_service_assign_public_ip" {
  description = "Should be true, if ECS service is using public subnets (more info: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_cannot_pull_image.html)"
  type        = bool
  default     = false
}

variable "policies_arn" {
  description = "A list of the ARN of the policies you want to apply"
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
}

variable "ecs_service_desired_count" {
  description = "The number of instances of the task definition to place and keep running"
  type        = number
  default     = 1
}

variable "ecs_service_deployment_maximum_percent" {
  description = "The upper limit (as a percentage of the service's desiredCount) of the number of running tasks that can be running in a service during a deployment"
  type        = number
  default     = 200
}

variable "ecs_service_deployment_minimum_healthy_percent" {
  description = "The lower limit (as a percentage of the service's desiredCount) of the number of running tasks that must remain running and healthy in a service during a deployment"
  type        = number
  default     = 50
}

variable "ecs_task_cpu" {
  description = "The number of cpu units used by the task"
  type        = number
  default     = 256
}

variable "ecs_task_memory" {
  description = "The amount (in MiB) of memory used by the task"
  type        = number
  default     = 512
}

variable "container_memory_reservation" {
  description = "The amount of memory (in MiB) to reserve for the container"
  type        = number
  default     = 128
}

variable "custom_container_definitions" {
  description = "A list of valid container definitions provided as a single valid JSON document. By default, the standard container definition is used."
  type        = string
  default     = ""
}

# app
variable "app_image" {
  description = "Docker image to run app with. If not specified, official app image will be used"
  type        = string
  default     = ""
}

variable "app_port" {
  description = "Local port app should be running on. Default value is most likely fine."
  type        = number
  default     = 4141
}

variable "custom_environment_secrets" {
  description = "List of additional secrets the container will use (list should contain maps with `name` and `valueFrom`)"
  type = list(object(
    {
      name      = string
      valueFrom = string
    }
  ))
  default = []
}

variable "custom_environment_variables" {
  description = "List of additional environment variables the container will use (list should contain maps with `name` and `value`)"
  type = list(object(
    {
      name  = string
      value = string
    }
  ))
  default = []
}

variable "lb_extra_security_group_ids" {
  description = "List of one or more security groups to be added to the load balancer"
  type        = list(string)
  default     = []
}