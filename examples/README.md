## Examples

Full examples can be found in the corresponding TF files

### Basic:
```sh
module "basic_example" {
    source = "../"

    launch_template = {
        image_id = data.aws_ami.al2.id
    }
}
```

### Tags:
```sh
module "tags_example" {
    source = "../"

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

```

### Volumes:
```sh
module "volumes_example" {
    source = "../"

    launch_template = {
        image_id = data.aws_ami.al2.id

        volumes = [{
            device_name = "/dev/sdg"
            volume_size = 8
            volume_type = "gp2"
            encrypted   = true
        },
        {
            device_name           = "/dev/sdf"
            volume_size           = 8
            delete_on_termination = true
        }]
    }
}

```