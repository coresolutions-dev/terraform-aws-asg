data "aws_ami" "al2"{
    most_recent = true

    filter {
        name = "name"
        values = ["amzn2-ami-hvm-2.0.*.0-x86_64-gp2"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["137112412989"]
}
