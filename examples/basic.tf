module "basic_example" {
    source = "../"

    launch_template = {
        image_id = data.aws_ami.al2.id
    }
}
