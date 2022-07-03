#EC2-instance
#============

resource "aws_instance" "instance" {
    ami = "${lookup(var.AMI,var.AWS_EC2_Region)}"
    instance_type = var.instance_type_ec2
    key_name = var.key_name
    subnet_id = "${aws_subnet.public-subnet-1.id}"
    vpc_security_group_ids = ["${aws_security_group.ssh-allowed.id}"]
    tags = {
	Name = "koinx"
    }
}

#Security-group
#==============

resource "aws_security_group" "ssh-allowed" {
    vpc_id = "${aws_vpc.koinx-vpc.id}"

    egress {
	from_port = 0
	to_port = 0
	protocol = -1
	cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
	from_port = 22
	to_port = 22
	protocol ="tcp"
	cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
	from_port = 80
	to_port = 80
	protocol = "tcp"
	cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
	Name = "ssh-allowed"
    }
}
