resource "aws_security_group" "ec2_sg" {
    name = var.sg_name
    vpc_id = var.vpc_id
    tags = {
        Name = var.sg_name
        terraform = "true"
    }
    ingress {
        from_port = 0
        to_port = 65535
        protocol = "tcp"
        cidr_blocks = [var.vpc_cidr]
        description = " within VPC"
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = " Egress Traffic "
    }
}
