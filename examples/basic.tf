module "basic_example" {
    source = "coresolutions-ltd/asg/aws"

    launch_template = {
        image_id = data.aws_ami.al2.id
    }
}
