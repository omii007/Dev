variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "key_name"  {
        default = "terraform"
}

provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region     = "us-east-1"
}

resource "aws_instance" "nginx" {
  ami       = "ami-0ac019f4fcb7cb7e6"
  instance_type = "t2.micro"
  key_name  = "${var.key_name}"

  connection {
    user     = "ec2-user"
    private_key = "${file(var.private_key_name)}"
  }
 }