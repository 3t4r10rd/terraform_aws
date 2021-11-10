terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

#Acces to AWS
provider "aws" {
  region     = "eu-west-1"
  access_key = "${file("~/aws/access")}"
  secret_key = "${file("~/aws/secret")}"
}

#Description of instance
resource "aws_instance" "aws1" {
  ami           = "ami-08edbb0e85d6a0a07"
  instance_type = "t2.micro"
#Public key for SSH connection
  key_name = "test-key"
  
  connection {
      type     = "ssh"
      user     = "ubuntu"
      host     = "${aws_instance.aws1.public_ip}"
#Private key for SSH
      private_key = "${file("~/.ssh/id_rsa")}"
  } 
#Copy test file to instance
  provisioner "file" {
    source      = "/index.html"
#To tmp directory, because without root priveleges
    destination = "/tmp/index.html"
  }
#Commands on instance 
  provisioner "remote-exec" {
    inline = [
      "sudo apt  update",
      "sudo apt install nginx -y",
      "sudo mv /tmp/index.html /var/www/html/index.html",
      "sudo service nginx restart"
    ]
  }
}

#Public key for SSH connection
resource "aws_key_pair" "deployer" {
  key_name = "test-key"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}
