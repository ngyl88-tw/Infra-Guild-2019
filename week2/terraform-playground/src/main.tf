provider "aws" {
  region = "ap-southeast-1"
}

# Create a new AWS Instance
resource "aws_instance" "example" {
  ami           = "ami-061eb2b23f9f8839c"
  instance_type = "t2.micro"
}