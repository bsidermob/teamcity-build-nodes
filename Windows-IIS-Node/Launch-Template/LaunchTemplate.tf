provider "aws" {
  region                  = "ap-southeast-2"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = ""
}

data "template_file" "user_data" {
  template = "${file("ec2-userdata")}"

}

resource "aws_iam_instance_profile" "on-demand-dev-vm-profile" {
  name = "ondemand-dev-vm"
  role = "${aws_iam_role.on-demand-dev-vm-pass-role.name}"
}

resource "aws_iam_role_policy" "on-demand-dev-vm-policy" {
  name = "on-demand-dev-vm-policy"
  role = "${aws_iam_role.on-demand-dev-vm-pass-role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "ec2:Describe*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:GetRole",
                "iam:PassRole",
                "iam:PutRolePolicy"
            ],
            "Resource": [
                "arn:aws:iam::198689915409:role/on-demand-dev-vm-role"
            ]
        }
    ]
}
EOF
}


resource "aws_iam_role" "on-demand-dev-vm-pass-role" {
  name = "on-demand-dev-vm-role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}


data "aws_ami" "TeamCity-BuildNode-IIS-Windows" {
  most_recent = true
  filter {
    name = "name"
    values = ["${var.ami_name}"]
  }
}

resource "aws_launch_template" "Dev-VM-template" {
  name = "${var.template_name}"
  iam_instance_profile = {
    arn = "${aws_iam_instance_profile.on-demand-dev-vm-profile.arn}"
  }
  image_id = "${data.aws_ami.TeamCity-BuildNode-IIS-Windows.id}"

  instance_initiated_shutdown_behavior = "terminate"

  instance_type = "t2.medium"


  network_interfaces {
    associate_public_ip_address = false
    security_groups = ["${var.security_groups}"]
    subnet_id = "${var.subnet_id}"
    device_index = "0"

  }

  tag_specifications {
    resource_type = "instance"
    tags {
      Name = "${var.tag}"
    }
  }

  user_data = "${base64encode(data.template_file.user_data.rendered)}"
}
