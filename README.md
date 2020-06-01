[![alt text](https://coresolutions.ltd/media/core-solutions-82.png "Core Solutions")](https://coresolutions.ltd)

[![maintained by Core Solutions](https://img.shields.io/badge/maintained%20by-coresolutions.ltd-00607c.svg)](https://coresolutions.ltd)
[![GitHub tag](https://img.shields.io/github/v/tag/coresolutions-ltd/terraform-aws-asg.svg?label=latest)](https://github.com/coresolutions-ltd/terraform-aws-asg/releases)
[![Terraform Version](https://img.shields.io/badge/terraform-~%3E%200.12.20-623ce4.svg)](https://github.com/hashicorp/terraform/releases)
[![License](https://img.shields.io/badge/License-Apache%202.0-brightgreen.svg)](https://opensource.org/licenses/Apache-2.0)

# Core Auto Scaling Group Terraform Module

A Terraform module to provison a fully working ASG that's natively integrated with Launch Template functionality.

## Getting Started
The below example fetches the latest Amazon Linux 2 AMI and creates an ASG & Launch Template using all of the default values.

```sh
module "basic" {
    source  = "coresolutions-ltd/asg/aws"
    version = "~> 0.0.1"

    launch_template = {
        image_id = data.aws_ami.al2.id
    }
}

data "aws_ami" "al2" {
    ...
}
```

More examples can be found [here](https://github.com/coresolutions-ltd/terraform-aws-asg/tree/master/examples).


## Inputs
|          Name          |                                            Description                                              |    Type     | Default | Required |
| ---------------------- | --------------------------------------------------------------------------------------------------- | ----------- | --------| ---------|
| name | The name of the auto scaling group, if ommited one will be auto generated | string | None | No |
| prefix | if `true` the name will become the prefix | bool | false | No |
| max_size | The maximum size of the auto scale group | number | 1 | No |
| min_size | The minimum size of the auto scale group | number | 0 | No |
| desired_capacity | The number of Amazon EC2 instances that should be running in the group | number | 0 | No |
| vpc_zone_identifier | A list of subnet IDs to launch resources in | list(string) | [] | No
| default_cooldown | The amount of time, in seconds, after a scaling activity completes before another scaling activity can start | number | None | No |
| health_check_grace_period | Time (in seconds) after instance comes into service before checking health | number | None | No |
| health_check_type | "EC2" or "ELB". Controls how health checking is done | string | EC2 | No |
| force_delete | Allows deleting the autoscaling group without waiting for all instances in the pool to terminate | bool | false | No |
| load_balancers | A list of elastic load balancer names to add to the autoscaling group names. Only valid for classic load balancers. For ALBs, use target_group_arns instead | list(string) | None | No |
| target_group_arns | A list of aws_alb_target_group ARNs, for use with Application or Network Load Balancing | list(string) | [] | No |
| termination_policies | A list of policies to decide how the instances in the auto scale group should be terminated. Allowed values are `OldestInstance` `NewestInstance` `OldestLaunchConfiguration` `ClosestToNextInstanceHour` `OldestLaunchTemplate` `AllocationStrategy` `Default` | list(string) | ["OldestInstance"] | No |
| suspended_processes | A list of processes to suspend for the AutoScaling Group. Allowed values are `Launch` `Terminate` `HealthCheck` `ReplaceUnhealthy` `AZRebalance` `AlarmNotification` `ScheduledActions` `AddToLoadBalancer` | list(string) | [] | No |
| enabled_metrics | A list of metrics to collect. The allowed values are `GroupDesiredCapacity` `GroupInServiceCapacity` `GroupPendingCapacity` `GroupMinSize` `GroupMaxSize` `GroupInServiceInstances` `GroupPendingInstances` `GroupStandbyInstances` `GroupStandbyCapacity` `GroupTerminatingCapacity` `GroupTerminatingInstances` `GroupTotalCapacity` `GroupTotalInstances`  | list(string) | [] | No |
| wait_for_capacity_timeout | A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. Setting this to "0" causes Terraform to skip all Capacity Waiting behavior | number | None | No |
| min_elb_capacity | Setting this causes Terraform to wait for this number of instances from this autoscaling group to show up healthy in the ELB only on creation  | number | None | No |
| wait_for_elb_capacity | Setting this will cause Terraform to wait for exactly this number of healthy instances from this autoscaling group in all attached load balancers on both create and update operations (Takes precedence over min_elb_capacity behavior) | number | None | No |
| protect_from_scale_in | Allows setting instance protection. The autoscaling group will not select instances with this setting for terminination during scale in events | bool | false | No |
| service_linked_role_arn | The ARN of the service-linked role that the ASG will use to call other AWS services | string | None | No |
| max_instance_lifetime | The maximum amount of time, in seconds, that an instance can be in service, values must be either equal to 0 or between 604800 and 31536000 seconds | number | None | No |
| shared_tags |  Tags for all resources that support tagging, these are merged with the specified tags for each resource | map(string) | None | No |
| asg_tags    |  Tags for the ASG only | map(string) | None | No |
| propagate_asg_tags |  Enables propagation of the tag to Amazon EC2 instances launched via the ASG, we recommend using the launch template `instance_tags` & `volume_tags` instead of propogating via the ASG. | bool | false | No |
| launch_template | Nested argument with Launch template specification to use to launch instance | object | None | Yes |


### The **launch_template** object support the following:
|          Name          |                                            Description                                              |    Type     | Default | Required |
| ---------------------- | --------------------------------------------------------------------------------------------------- | ----------- | --------| ---------|
| image_id | The AMI from which to launch the instance | string | None | Yes |
| iam_instance_profile_arn | The IAM Instance Profile ARN to launch the instance with, conflicts with `iam_instance_profile_name`| 
| iam_instance_profile_name | The IAM Instance Profile name to launch the instance with, conflicts with `iam_instance_profile_arn`| 
| description | Description of the launch template | string | None | No |
| volumes | Specify volumes to attach to the instance besides the volumes specified by the AMI. See launch_template(volumes) object below for details | object | None | No |
| capacity_reservation_preference | Indicates the instance's Capacity Reservation preferences. Can be `open` or `none` | string | None | No |
| capacity_reservation_id | The ID of the Capacity Reservation to target | string | None | No |
| cpu_core_count | The number of CPU cores for the instance | number | None | No |
| threads_per_core | The number of threads per CPU core. To disable Intel Hyper-Threading Technology for the instance, specify a value of 1. Otherwise, specify the default value of 2. Both number of CPU cores and threads per core must be specified. Valid number of CPU cores and threads per core for the instance type can be found in the [CPU Options Documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-optimize-cpu.html?shortFooter=true#cpu-options-supported-instances-values) | number | None | No |
| cpu_credits | The credit option for CPU usage. Can be "standard" or "unlimited". T3 instances are launched as unlimited by default. T2 instances are launched as standard by default | number | None | No |
| instance_termination_protection | If true, enables EC2 Instance Termination Protection | bool | None | No |
| ebs_optimized | If true, the launched EC2 instance will be EBS-optimized | bool | None | No |
| elastic_gpu_type | The [elastic GPU type](https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/elastic-gpus.html#elastic-gpus-basics) to attach to the instance | string | None | No |
| elastic_inference_accelerator_type | Attach an [Elastic Inference Accelerator](https://docs.aws.amazon.com/elastic-inference/latest/developerguide/basics.html) to the instance | string | None | No |
| instance_initiated_shutdown_behavior | Shutdown behavior for the instance. Can be `stop` or `terminate` | string | stop | No |
| spot_options | The spot purchasing options for the instance, see launch_template(spot_options) object below for details | object | None | No |
| instance_type | The type of the instance | string | t2.micro | No |
| kernel_id | The kernel ID | string | None | No |
| key_name | The key name to use for the instance | string | None | No |
| license_configuration_arn | ARN of the licence configuration to associate with | string | None | No |
| metadata_options | Metadata options for the instance. See launch_template(metadata_options) below for more details | object | None | No |
| detailed_monitoring | If true, the launched EC2 instance will have detailed monitoring enabled | bool | false | No |
| network_interface | Define the network interface to be attached at instance boot time. See launch_template(network_interface) below for more details | object | None | No |
| placement | The placement of the instance. See launch_template(placement) below for more details | object | None | No |
| ram_disk_id | The ID of the RAM disk | string | None | No |
| security_group_ids | A list of security group IDs to associate with | list(string) | None | No |
| user_data | The Base64-encoded user data to provide when launching the instance.
| hibernation | If set to `true` the launched EC2 instance will have hibernation enabled | bool | None | No |
| lt_tags | Launch Template tags | map(string) | None | No |
| instance_tags | Instance tags | map(string) | None | No |
| volume_tags | Volume tags | map(string) | None | No |

>If no iam_instance_profile details are supplied a role and corresponding profile one will be auto created with the `CloudWatchAgentServerPolicy` & `AmazonSSMManagedInstanceCore` policies attached 


### objects in the **launch_template(volumes)** list support the following:
|          Name          |                                            Description                                              |    Type     | Default | Required |
| ---------------------- | --------------------------------------------------------------------------------------------------- | ----------- | --------| ---------|
| device_name | The name of the device to mount | string | None | Yes |
| no_device   | Suppresses the specified device included in the AMI's block device mapping | string | None | No |
| virtual_name | The Instance Store Device Name (e.g. "ephemeral0") | string | None | No |
| volume_size | The size of the volume in gigabytes | number | None | Yes |
| volume_type | The type of volume. Can be `standard` `gp2` or `io1` | string | standard | No |
| delete_on_termination | Whether the volume should be destroyed on instance termination, see [Preserving Amazon EBS Volumes on Instance Termination](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/terminating-instances.html#preserving-volumes-on-termination) for more information | bool | false | No |
| encrypted | Enables EBS encryption on the volume, cannot be used with snapshot_id | bool | false | No |
| iops | The amount of provisioned [IOPS](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-io-characteristics.html). This must be set with a volume_type of `io1` |  string | None | No |
| kms_key_id | The ARN of the AWS Key Management Service (AWS KMS) customer master key (CMK) to use when creating the encrypted volume. `encrypted` must be set to `true` when this is set  | string | None | No |       
| snapshot_id | The Snapshot ID to mount | string | None | No |

> if neither `no_device` or `virtual_name` is supplied EBS volume is assumed


### The **launch_template(spot_options)** object support the following:
|          Name          |                                            Description                                              |    Type     | Default | Required |
| ---------------------- | --------------------------------------------------------------------------------------------------- | ----------- | --------| ---------|
| block_duration_minutes | The required duration in minutes. This value must be a multiple of 60 | number | None | Yes |
| instance_interruption_behavior | The behavior when a Spot Instance is interrupted. Can be `hibernate` `stop` or `terminate` | string | terminate | No |
| max_price | The maximum hourly price you're willing to pay for the Spot Instances | number | None | Yes |
| spot_instance_type | The Spot Instance request type. Can be `one-time` or `persistent` | string | one-time | No |
| valid_until | The end date of the request | string | None | No |

### The **launch_template(metadata_options)** object support the following:
|          Name          |                                            Description                                              |    Type     | Default | Required |
| ---------------------- | --------------------------------------------------------------------------------------------------- | ----------- | --------| ---------|
| http_endpoint | Whether the metadata service is available. Can be `enabled` or `disabled` | string | enabled | No |
| http_tokens | Whether or not the metadata service requires session tokens. Can be `optional` or `required` | string | optional | No |
| http_put_response_hop_limit | The desired HTTP PUT response hop limit for instance metadata requests. The larger the number, the further instance metadata requests can travel. Can be an integer from 1 to 64 | number | 1 | No | 

### The **launch_template(network_interface)** object support the following:
|          Name          |                                            Description                                              |    Type     | Default | Required |
| ---------------------- | --------------------------------------------------------------------------------------------------- | ----------- | --------| ---------|
| associate_public_ip_address | Associate a public ip address with the network interface. | bool | None | No | 
| delete_on_termination | Whether the network interface should be destroyed on instance termination | bool | None | No | 
| description | Description of the network interface | string | None | No |
| ipv6_addresses | One or more specific IPv6 addresses from the IPv6 CIDR block range of your subnet. *Conflicts with ipv6_address_count* | list(string) | None | No |
| ipv6_address_count | The number of IPv6 addresses to assign to a network interface. *Conflicts with ipv6_addresses* | number | None | No |
| network_interface_id | The ID of the network interface to attach | string | None | No |
| security_groups | A list of security group IDs to associate | list(string) | None | No |
| subnet_id | The VPC Subnet ID to associate | string | None | Yes |
>When creating a launch template for use with an Auto Scaling group multiple network interfaces are not supported

### The **launch_template(placement)** object support the following:
|          Name          |                                            Description                                              |    Type     | Default | Required |
| ---------------------- | --------------------------------------------------------------------------------------------------- | ----------- | --------| ---------|
affinity - The affinity setting for an instance on a Dedicated Host | string | None | No |
availability_zone - The Availability Zone for the instance | string | None | No |
group_name - The name of the existing placement group for the instance | string | None | Yes |
strategy | Omit `group_name` and set `strategy` to create and use a new placement group. values can be `cluster` `partition` `spread` | string | No |
host_id - The ID of the Dedicated Host for the instance | string | None | No |
tenancy | The tenancy of the instance. Can be `default` `dedicated` or `host` | string | default | No |
partition_number - The number of the partition the instance should launch in. Can be 1 or 2, valid only if the placement group strategy is set to partition | number | None | No | 

## Outputs
|             Name               |           Description           |
| ------------------------------ | ------------------------------- |
| asg_id | The autoscaling group id |
| asg_arn | The ARN for the AutoScaling Group |
| asg_availability_zones | The availability zones of the autoscale group |
| asg_min_size | The minimum size of the autoscale group |
| asg_max_size | The maximum size of the autoscale group |
| asg_default_cooldown | Time between a scaling activity and the succeeding scaling activity |
| asg_name | The name of the autoscale group |
| asg_health_check_grace_period | Time after instance comes into service before checking health |
| asg_health_check_type | `EC2` or `ELB` Controls how health checking is done |
| asg_desired_capacity | The number of Amazon EC2 instances that should be running in the group |
| asg_vpc_zone_identifier | The VPC zone identifier |
| asg_load_balancers | The load balancer names associated with the autoscaling group |
| asg_target_group_arns | list of Target Group ARNs that apply to the AutoScaling Group |
| lt_arn | Amazon Resource Name (ARN) of the launch template |
| lt_id | The ID of the launch template |
| lt_default_version | The default version of the launch template |
| lt_latest_version | The latest version of the launch template |