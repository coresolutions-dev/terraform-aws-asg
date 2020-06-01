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
