resource "aws_db_subnet_group" "mysql" {
  name       = "mysql"
  subnet_ids = data.terraform_remote_state.vpc.outputs.PRIVATE_SUBNETS

  tags = {
    Name = "MySQL DB subnet group"
  }
}
