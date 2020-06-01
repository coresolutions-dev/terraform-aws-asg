module "network_interface_example" {
    source = "../"

    launch_template = {
        image_id = data.aws_ami.al2.id

        # Create and use a new placement group with a cluster strategy.
        placement = {
            "strategy" = "cluster"
        }

        
}
