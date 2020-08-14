module "volumes_example" {
    source              = ".coresolutions-ltd/asg/aws"
    vpc_zone_identifier = [aws_subnet.example1.id, aws_subnet.example2.id]

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
