data "aws_vpc" "default" {
  default = true
}

data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
  name = "default"
}

resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = data.aws_security_group.default.id

  cidr_blocks = var.whitelisted_cidrs
  description = "infra-guild-week2: allow SSH from Office and Home IP"
}

resource "aws_security_group_rule" "allow_http" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  security_group_id = data.aws_security_group.default.id

  cidr_blocks = var.whitelisted_cidrs
  description = "infra-guild-week2: allow http call from Office and Home IP"
}
