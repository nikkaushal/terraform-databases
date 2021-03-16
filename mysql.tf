resource "aws_db_subnet_group" "mysql" {
  name       = "mysql"
  subnet_ids = data.terraform_remote_state.vpc.outputs.PRIVATE_SUBNETS

  tags = {
    Name = "MySQL DB subnet group"
  }
}

resource "aws_db_parameter_group" "mysql" {
  name   = "mysql-pg"
  family = "mysql5.7"
}


resource "aws_rds_cluster" "mysql" {
  cluster_identifier                  = "mysql-${var.ENV}"
  engine                              = "aurora-mysql"
  engine_version                      = "5.7.mysql_aurora.2.03.2"
  db_subnet_group_name                = aws_db_subnet_group.mysql.name
  database_name                       = "defaultdb"
  master_username                     = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)["MYSQL_USER"]
  master_password                     = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)["MYSQL_PASSWORD"]
  backup_retention_period             = 5
  preferred_backup_window             = "07:00-09:00"
  db_cluster_parameter_group_name     = aws_db_parameter_group.mysql.name
}