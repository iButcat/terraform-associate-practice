resource "aws_security_group" "db" {
  name        = "${var.environment}-db-sg"
  description = "Security group for database"
  vpc_id      = var.vpc_id
  
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = var.allowed_security_group_ids
    description     = "MySQL from web tier"
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(
    {
      Name        = "${var.environment}-db-sg"
      Environment = var.environment
    },
    var.tags
  )
}

resource "aws_db_subnet_group" "db" {
  name        = "${var.environment}-db-subnet-group"
  subnet_ids  = var.subnet_ids
  description = "DB subnet group for ${var.environment}"
  
  tags = merge(
    {
      Name        = "${var.environment}-db-subnet-group"
      Environment = var.environment
    },
    var.tags
  )
}

resource "aws_db_instance" "db" {
  identifier             = "${var.environment}-db"
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = var.instance_class
  db_name                = var.database_name
  username               = var.username
  password               = var.password
  parameter_group_name   = "default.mysql5.7"
  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name   = aws_db_subnet_group.db.name
  skip_final_snapshot    = true
  
  tags = merge(
    {
      Name        = "${var.environment}-db"
      Environment = var.environment
    },
    var.tags
  )
} 