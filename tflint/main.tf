resource "aws_security_group" "example_sg" {
  name        = "example_security_group"
  description = "Example security group for demonstrating TFLint best practices"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["192.168.1.0/24"] # Hard-coded CIDR block #var.ingress_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.microo" # Invalid instance type
}

resource "aws_s3_bucket" "bucket-name" { 
  bucket = "my-unique-bucket-name"
  acl    = "private"
}