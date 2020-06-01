module "network_interface_example" {
    source = "../"

    launch_template = {
        image_id = data.aws_ami.al2.id

        network_interface = {
            delete_on_termination = true
            associate_public_ip_address = true
            ipv6_address_count = 1
        }
    }
}
