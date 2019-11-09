provider "aws" {
  region     = "ap-southeast-1"
}

# Create a new AWS Instance
resource "aws_instance" "example" {
  ami           = "ami-061eb2b23f9f8839c"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name
}

resource "aws_key_pair" "deployer" {
  key_name   = "macbook-pro-2018-15-inch"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/6tid2po4rN0zcO4hUXmJeIWcoP2u8eGnpjmcGVGSg8V6hr7a9Iee0dMOi/hbhFiUT0NTh+tyaHBHwwIYCMyWhDtwyzOBv+Ss5HEcpx6niJQpxDLITCEQF8Sh+ELmaX8LvGo2QQw27QNUB4WARrQwiV9S/d9R0ApRlXnLO6+8BQk0F6ZGej3KXccTyzLGf0DTBlC9Nr3UHjf3H7kfetKOQqtpgZXhXTXgQYeaKZkLtbd9KywPrGCYpVsSXMlV6OGf77WCGzDAO9UmXZQpEaagS4LmoqWbcNNTsnj9rNT8pywIlrf9FpWDtQB5Z34xD2t/Y3G2sDp0VYSPgtYVqBoI9pntPwhTJDvMn+4fHJjZbsyLW3V74iyvjJHHSGAAMFdYwNZqA4jhIaum7wG4c495uyonUIirmnJ3+BcR3JhuydDXudsBpay09coaUUBWxQGahubhrgToV1TnxcY7kQknduL7RLA1+aLKZbQVecb5lgqA/0tmuOl+SOdGAZP+DaYxEpLddjiF8MFA/yZUjWahUj80cMJ2vMXibwtfQ1zH7XOpmWYEaJDi8GVuCj94+e5xERU4RAvszRAbB4I6Zac+LcOKdvVmhzc5aG2mlunFt2tOXxaYPGgBXjIhB+9pyNLnzmey+nGlpHQu4LK51j/cjXhozMDfEcBsZnJ7H/cACw== ng_yl88@hotmail.com"
}

# Get default vpc so that we can access the instance
data "aws_vpc" "default" {
  default = true
}

data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "allow_ssh" {
  type            = "ingress"
  from_port       = 22
  to_port         = 22
  protocol        = "tcp"
  security_group_id = data.aws_security_group.default.id

  cidr_blocks = var.whitelisted_cidrs
  description = "Allow SSH from Office IP"
}