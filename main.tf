locals {
    init_name = var.name != null ? var.name : "Core-${random_id.rand.0.dec}"
    name = var.prefix ? "${local.init_name}-${random_id.rand.0.dec}" : local.init_name
    asg_tags = lookup(var.asg_tags, "Name", null) == null ? [
        for k, v in merge(var.shared_tags, var.asg_tags, {"Name" = "${local.name}-ASG"}) : {
            key                 = k
            value               = v
            propagate_at_launch = var.propagate_asg_tags
        }  
    ] : [
        for k, v in merge(var.shared_tags, var.asg_tags) : {
            key                 = k
            value               = v
            propagate_at_launch = var.propagate_asg_tags
        }  
    ]
    lt_tags       = try(var.launch_template.lt_tags.Name, null) == null ? merge(var.shared_tags, lookup(var.launch_template, "lt_tags", {}), {"Name" = "${local.name}-LT"}) : merge(var.shared_tags, lookup(var.launch_template, "lt_tags", {})) 
    instance_tags = try(var.launch_template.instance_tags.Name, null) == null ? merge(var.shared_tags, lookup(var.launch_template, "instance_tags", {}), {"Name" = local.name}) : merge(var.shared_tags, lookup(var.launch_template, "instance_tags", {}))
    volume_tags   = try(var.launch_template.volume_tags.Name, null) == null ? merge(var.shared_tags, lookup(var.launch_template, "volume_tags", {}), {"Name" = local.name}) : merge(var.shared_tags, lookup(var.launch_template, "volume_tags", {}))
}


resource "random_id" "rand" {
    count = var.name == null || var.prefix == true ? 1 : 0
    byte_length = 4
}


resource "aws_autoscaling_group" "asg" {
    name                      = "${local.name}-ASG"
    default_cooldown          = var.default_cooldown
    desired_capacity          = var.desired_capacity
    max_size                  = var.max_size
    min_size                  = var.min_size
    health_check_grace_period = var.health_check_grace_period
    health_check_type         = var.health_check_type 
    force_delete              = var.force_delete
    load_balancers            = var.load_balancers
    target_group_arns         = var.target_group_arns
    vpc_zone_identifier       = var.vpc_zone_identifier
    termination_policies      = var.termination_policies
    suspended_processes       = var.suspended_processes
    placement_group           = var.placement_group
    enabled_metrics           = var.enabled_metrics
    wait_for_capacity_timeout = var.wait_for_capacity_timeout
    min_elb_capacity          = var.min_elb_capacity
    wait_for_elb_capacity     = var.wait_for_elb_capacity
    protect_from_scale_in     = var.protect_from_scale_in
    service_linked_role_arn   = var.service_linked_role_arn
    max_instance_lifetime     = var.max_instance_lifetime
    tags                      = local.asg_tags

    dynamic "launch_template" {
        for_each = var.launch_template != {} ? [1] : []

        content {
            id      = aws_launch_template.lt.0.id
            version = "$Latest"
        }
    }
}


resource "aws_launch_template" "lt" {
    count                                = var.launch_template != {} ? 1 : 0
    name                                 = "${local.name}-LT"
    description                          = lookup(var.launch_template, "description", null)
    image_id                             = lookup(var.launch_template, "image_id", null)
    instance_type                        = lookup(var.launch_template, "instance_type", "t2.micro")
    disable_api_termination              = lookup(var.launch_template, "instance_termination_protection", null)
    ebs_optimized                        = lookup(var.launch_template, "ebs_optimized", null)
    instance_initiated_shutdown_behavior = lookup(var.launch_template, "instance_initiated_shutdown_behavior", null)
    kernel_id                            = lookup(var.launch_template, "kernel_id", null)
    key_name                             = lookup(var.launch_template, "key_name", null)
    ram_disk_id                          = lookup(var.launch_template, "ram_disk_id", null)
    user_data                            = lookup(var.launch_template, "user_data", null)
    vpc_security_group_ids               = lookup(var.launch_template, "security_group_ids", null)
    tags                                 = local.lt_tags

    dynamic "block_device_mappings" {
        for_each = lookup(var.launch_template, "volumes", null) != null ? var.launch_template.volumes : []
        iterator = volume

        content {
            device_name  = volume.value.device_name
            no_device    = lookup(volume.value, "no_device", null)
            virtual_name = lookup(volume.value, "virtual_name", null)

            dynamic "ebs" {
                for_each = lookup(volume.value, "no_device", null) == null && lookup(volume.value, "virtual_name", null) == null ? [1] : []

                content {
                    volume_size           = lookup(volume.value, "volume_size", null)
                    volume_type           = lookup(volume.value, "volume_type", null)
                    delete_on_termination = lookup(volume.value, "delete_on_termination", null)
                    encrypted             = lookup(volume.value, "encrypted", null)
                    iops                  = lookup(volume.value, "iops", null)
                    kms_key_id            = lookup(volume.value, "kms_key_id", null)
                    snapshot_id           = lookup(volume.value, "snapshot_id", null)
                }
            }
        }
    }

    dynamic "capacity_reservation_specification" {
        for_each = lookup(var.launch_template, "capacity_reservation_preference", null) != null || lookup(var.launch_template, "capacity_reservation_id", null) != null ? [1] : []

        content {
            capacity_reservation_preference = lookup(var.launch_template, "capacity_reservation_preference", null)

            dynamic "capacity_reservation_target" {
                for_each = lookup(var.launch_template, "capacity_reservation_id", null) != null ? [1] : []

                content {
                    capacity_reservation_id = lookup(var.launch_template, "capacity_reservation_id", null)
                }
            }
        }
    }

    dynamic "cpu_options" {
        for_each = lookup(var.launch_template, "cpu_core_count", null) != null && lookup(var.launch_template, "threads_per_core", null) != null ? [1] : []

        content {
            core_count       = var.launch_template["cpu_core_count"]
            threads_per_core = var.launch_template["threads_per_core"]
        }
    }

    dynamic "credit_specification" {
        for_each = lookup(var.launch_template, "cpu_credits", null) != null ? [1] : []

        content {
            cpu_credits = var.launch_template["cpu_credits"]
        }
    }

    dynamic "elastic_gpu_specifications" {
        for_each = lookup(var.launch_template, "elastic_gpu_type", null) != null ? [1] : []

        content {
            type = var.launch_template["elastic_gpu_type"]
        }
    }

    dynamic "elastic_inference_accelerator" {
        for_each = lookup(var.launch_template, "elastic_inference_accelerator_type", null) != null ? [1] : []

        content {
            type = var.launch_template["elastic_inference_accelerator_type"]
        }
    }

    dynamic "license_specification" {
        for_each = lookup(var.launch_template, "license_configuration_arn", null) != null ? [1] : []

        content {
            license_configuration_arn  = var.launch_template["license_configuration_arn"]
        }
    }

    dynamic "instance_market_options" {
        for_each = lookup(var.launch_template, "spot_options", null) != null ? [var.launch_template.spot_options] : []
        iterator = spot_options

        content {
            market_type = "spot"

            spot_options { 
                block_duration_minutes         = lookup(spot_options.value, "block_duration_minutes", null)
                instance_interruption_behavior = lookup(spot_options.value, "instance_interruption_behavior", null)
                max_price                      = lookup(spot_options.value, "max_price", null)
                spot_instance_type             = lookup(spot_options.value, "spot_instance_type", "one-time")
                valid_until                    = lookup(spot_options.value, "valid_until", null)
            }
        }
    }

    dynamic "metadata_options" {
        for_each = lookup(var.launch_template, "metadata_options", null) != null ? [var.launch_template.metadata_options] : []

        content {
            http_endpoint               = lookup(metadata_options.value, "http_endpoint", null)
            http_tokens                 = lookup(metadata_options.value, "http_tokens", null)
            http_put_response_hop_limit = lookup(metadata_options.value, "http_put_response_hop_limit", null)
        }
    }

    dynamic "monitoring" {
        for_each = lookup(var.launch_template, "detailed_monitoring", false) ? [1] : []

        content {
            enabled = lookup(var.launch_template, "detailed_monitoring", false)
        }
    }

    dynamic "network_interfaces" {
        for_each = lookup(var.launch_template, "network_interface", null) != null ? [var.launch_template.network_interface] : []
        iterator = interface

        content {
            associate_public_ip_address = lookup(interface.value, "associate_public_ip_address", null)
            delete_on_termination       = lookup(interface.value, "delete_on_termination", null)
            description                 = lookup(interface.value, "description", null)
            ipv6_addresses              = lookup(interface.value, "ipv6_addresses", null)
            ipv6_address_count          = lookup(interface.value, "ipv6_address_count", null)
            network_interface_id        = lookup(interface.value, "network_interface_id", null)
            private_ip_address          = lookup(interface.value, "private_ip_address", null)
            ipv4_address_count          = lookup(interface.value, "ipv4_address_count", null)
            ipv4_addresses              = lookup(interface.value, "ipv4_addresses", null)
            security_groups             = lookup(interface.value, "security_groups", null)
            subnet_id                   = lookup(interface.value, "subnet_id", null)
        }
    }

    dynamic "placement" {
        for_each = lookup(var.launch_template, "placement", null) != null ? [var.launch_template.placement] : []

        content {
            affinity          = lookup(placement.value, "affinity", null)
            availability_zone = lookup(placement.value, "availability_zone", null)
            group_name        = lookup(placement.value, "group_name", null) == null ? aws_placement_group.pg.0.name : placement.value.group_name
            host_id           = lookup(placement.value, "host_id", null)
            spread_domain     = lookup(placement.value, "spread_domain", null)
            tenancy           = lookup(placement.value, "tenancy", null)
            partition_number  = lookup(placement.value, "partition_number", null)
        }
    }

    dynamic "hibernation_options" {
        for_each = lookup(var.launch_template, "hibernation", false) ? [1] : []

        content {
            configured = lookup(var.launch_template, "hibernation", false)
        }
    }

    dynamic "tag_specifications" {
        for_each = lookup(var.launch_template, "instance_tags", null) != null || var.shared_tags != {} ? [1] : []

        content {
            resource_type = "instance"
            tags = local.instance_tags
        }
    }

    dynamic "tag_specifications" {
        for_each = lookup(var.launch_template, "volume_tags", null) != null || var.shared_tags != {} ? [1] : []

        content {
            resource_type = "volume"
            tags = local.volume_tags
        }
    }

    iam_instance_profile {
        arn  = lookup(var.launch_template, "iam_instance_profile_arn", null) == null && lookup(var.launch_template, "iam_instance_profile_name", null) == null ? aws_iam_instance_profile.instance_profile.0.arn : lookup(var.launch_template, "iam_instance_profile_arn", null)
        name = lookup(var.launch_template, "iam_instance_profile_name", null)
    }
}

resource "aws_iam_role" "instance_role" {
    count = var.launch_template != {} && lookup(var.launch_template, "iam_instance_profile_arn", null) == null && lookup(var.launch_template, "iam_instance_profile_name", null) == null ? 1 : 0
    name = "${local.name}-Instance-Role"

    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

    tags = merge(var.shared_tags, {"Name" = "${local.name}-Instance-Role"})
}


resource "aws_iam_role_policy_attachment" "instance_role_ssm_core" {
    count = var.launch_template != {} && lookup(var.launch_template, "iam_instance_profile_arn", null) == null && lookup(var.launch_template, "iam_instance_profile_name", null) == null ? 1 : 0
    role  = aws_iam_role.instance_role.0.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_role_policy_attachment" "instance_role_cw" {
    count = var.launch_template != {} && lookup(var.launch_template, "iam_instance_profile_arn", null) == null && lookup(var.launch_template, "iam_instance_profile_name", null) == null ? 1 : 0
    role  = aws_iam_role.instance_role.0.name
    policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}


resource "aws_iam_instance_profile" "instance_profile" {
    count = var.launch_template != {} && lookup(var.launch_template, "iam_instance_profile_arn", null) == null && lookup(var.launch_template, "iam_instance_profile_name", null) == null ? 1 : 0
    name = "${local.name}-Instance-Profile"
    role = aws_iam_role.instance_role.0.name

}


resource "aws_placement_group" "pg" {
    count    = lookup(var.launch_template, "placement", null) != null && try(var.launch_template.placement.group_name, null) == null ? 1 : 0
    name     = "${local.name}-PG"
    strategy = var.launch_template.placement.strategy
}