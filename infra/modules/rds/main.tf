resource "aws_db_parameter_group" "diary_rds_pg" {
  name   = "diary-rds-pg"
  family = "mysql8.0"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }
  parameter {
    name  = "collation_server"
    value = "utf8mb4_unicode_ci"
  }
  parameter {
    name  = "time_zone"
    value = "Asia/Seoul"
  }
}


resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "team4-rds-subnet-group"
  subnet_ids = var.private_subnet_ids
}

resource "aws_db_instance" "diary_db" {
  allocated_storage     = 20
  max_allocated_storage = 100
  engine                = "mysql"
  engine_version        = "8.0"
  instance_class        = "db.t3.micro"

  db_name  = "diarydb"
  username = "admin"
  password = var.db_password

  port                   = 3306
  parameter_group_name   = aws_db_parameter_group.diary_rds_pg.name
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [var.rds_sg_id]
  skip_final_snapshot    = true
  publicly_accessible    = false
}
