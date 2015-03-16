variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "ami" { default = "" }

variable "prod" {
    default = {
        sg_id = ""
        subnet_id = ""
    }
}

provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "ap-northeast-1"
}

resource "aws_instance" "pool_instance" {
    ami = "${var.ami}"
    instance_type = "m3.medium"
    key_name = "clduser"

    count = 1

    tags {
        Name = "Pool host"
    }

    security_groups = ["${var.prod.sg_id}"]
    subnet_id = "${var.prod.subnet_id}"

    user_data = "${file("userdata/pool-userdata.yaml")}"
}

