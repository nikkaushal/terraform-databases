resource "aws_instance" "mongo" {
  ami                       = data.aws_ami.ami.id
  instance_type             = "t3.small"
  vpc_security_group_ids    = [aws_security_group.allow-mongo.id]
  key_name                  = "devopstest1"
  subnet_id                 = data.terraform_remote_state.vpc.outputs.PRIVATE_SUBNETS[0]
  tags = {
    Name = "mongo-${var.ENV}"
  }
}

//test
resource "aws_security_group" "allow-mongo" {
  name                    = "allow-mongo-${var.ENV}"
  description             = "allow-mongo-${var.ENV}"
  vpc_id                  = data.terraform_remote_state.vpc.outputs.VPC_ID

  ingress {
    description           = "SSH"
    from_port             = 27017
    to_port               = 27017
    protocol              = "tcp"
    cidr_blocks           = [data.terraform_remote_state.vpc.outputs.VPC_CIDR, data.terraform_remote_state.vpc.outputs.DEFAULT_VPC_CIDR]
  }

  ingress {
    description           = "SSH"
    from_port             = 22
    to_port               = 22
    protocol              = "tcp"
    cidr_blocks           = [data.terraform_remote_state.vpc.outputs.VPC_CIDR, data.terraform_remote_state.vpc.outputs.DEFAULT_VPC_CIDR]
  }

  egress {
    from_port             = 0
    to_port               = 0
    protocol              = "-1"
    cidr_blocks           = ["0.0.0.0/0"]
  }

  tags = {
    Name                  = "allow-mongo-${var.ENV}"
  }
}

resource "null_resource" "mongo-schema" {
  provisioner "remote-exec" {
    connection {
      host = aws_instance.mongo.private_ip
      user = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)["SSH_USER"]
      password = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)["SSH_PASS"]
      //hardcoding user id and pwd in code is not a good practise and causes securty breaches
    }
    inline = [
      "sudo yum install ansible -y",
      "ansible-pull -i localhost, -U https://github.com/nikkaushal/ansible.git roboshop-project/roboshop.yml -e ENV=${var.ENV} -e component=mongo -e PAT=${jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)["PAT"]} -t mongo"
    ]
  }
}

resource "aws_route53_record" "mongo" {
  name        = "mongo-${var.ENV}"
  type        = "A"
  zone_id     = data.terraform_remote_state.vpc.outputs.ZONE_ID
  ttl         = "1000"
  records     = [aws_instance.mongo.private_ip]
}