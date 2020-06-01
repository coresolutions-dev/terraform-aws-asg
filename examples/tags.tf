module "tags_example" {
    source = "coresolutions-ltd/asg/aws"

    shared_tags = {
        "foo_shared" = "bar"
        "bar_shared" = "foo"
    }

    asg_tags = {
        "foo_asg" = "bar"
        "bar_asg" = "foo"
    }

    launch_template = {
        image_id = data.aws_ami.al2.id

        lt_tags = {
            "foo_lt" = "bar"
        }

        volume_tags = {
            "foo_volume" = "bar"
            "bar_volume" = "foo"
        }

        instance_tags = {
            "foo_instance" = "bar"
            "bar_instance" = "foo"
        }
    }
}
