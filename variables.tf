variable "name" {
    description = "The name of the auto scaling group"
    type        = string
    default     = null
}

variable "prefix" {
    description = "If true creates a unique name using the specified name variable as a prefix"
    type        = bool
    default     = false
}

variable "min_size" {
    description = "The maximum size of the auto scale group"
    type        = number
    default     = 0
}

variable "max_size" {
    description = "The minimum size of the auto scale group"
    type        = number
    default     = 1
}

variable "desired_capacity" {
    description = "The number of Amazon EC2 instances that should be running in the group"
    type        = number
    default     = 0
}

variable "vpc_zone_identifier" {
    description = "A list of subnet IDs to launch resources in"
    type        = list(string)
    default     = []
}

variable "launch_template" {
    description = "Launch template specification to use to launch instance"
    type        = any
    default     = {}
}

variable "termination_policies" {
    description = "A list of policies to decide how the instances in the auto scale group should be terminated"
    type        = list(string)
    default     = ["OldestInstance"]
}

variable "shared_tags" {
    description = "Tags for all resources created that support tagging"
    type        = map(string)
    default     = {}
}

variable "asg_tags" {
    description = "ags for the ASG only"
    type        = map(string)
    default     = {}
}

variable "propagate_asg_tags" {
    description = "Enables propagation of the tag to Amazon EC2 instances launched via the ASG"
    type        = bool
    default     = false
}

variable "health_check_type" {
    description = "EC2 or ELB. Controls how health checking is done"
    type        = string
    default     = "EC2"
}

variable "health_check_grace_period" {
    description = "Time (in seconds) after instance comes into service before checking health"
    type        = number
    default     = 300
}

variable "protect_from_scale_in" {
    description = "Allows setting instance protection. The autoscaling group will not select instances with this setting for terminination during scale in events"
    type        = bool
    default     = false
}

variable "service_linked_role_arn" {
    description = "The ARN of the service-linked role that the ASG will use to call other AWS services"
    type        = string
    default     = null
}

variable "wait_for_elb_capacity" {
    description = "Setting this will cause Terraform to wait for exactly this number of healthy instances from this autoscaling group in all attached load balancers on both create and update operations (Takes precedence over min_elb_capacity behavior)"
    type       = number
    default    = null
}

variable "min_elb_capacity" {
    description = "Setting this causes Terraform to wait for this number of instances from this autoscaling group to show up healthy in the ELB only on creation"
    type        = number
    default     = 0
}

variable "wait_for_capacity_timeout" {
    description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. Setting this to 0 causes Terraform to skip all Capacity Waiting behavior"
    type        = number
    default     = null
}

variable "max_instance_lifetime" {
    description = "The maximum amount of time, in seconds, that an instance can be in service, values must be either equal to 0 or between 604800 and 31536000 seconds"
    type        = number
    default     = null
}

variable "enabled_metrics" {
    description = "A list of metrics to collect"
    type        = list(string)
    default     = []
}

variable "placement_group" {
    description = "The name of the placement group into which you'll launch your instances into"
    type        = string
    default     = null
}

variable "suspended_processes" {
    description = "A list of processes to suspend for the AutoScaling Group"
    type        = list(string)
    default     = []
}

variable "target_group_arns" {
    description = "A list of aws_alb_target_group ARNs, for use with Application or Network Load Balancing"
    type        = list(string)
    default     = []
}

variable "load_balancers" {
    description = "A list of elastic load balancer names to add to the autoscaling group names. Only valid for classic load balancers. For ALBs, use target_group_arns instead"
    type        = list(string)
    default     = []
}

variable "force_delete" {
    description = "Allows deleting the autoscaling group without waiting for all instances in the pool to terminate"
    type        = bool
    default     = false
}

variable "default_cooldown" {
    description = "The amount of time, in seconds, after a scaling activity completes before another scaling activity can start"
    type        = number
    default     = null
}
