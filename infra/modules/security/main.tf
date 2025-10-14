resource "aws_security_group" "app" {
  name        = "${var.name}-app-sg"
  description = "Allow HTTP traffic to the application"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP access"
    from_port   = 8090
    to_port     = 8090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # for dev; restrict later
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-app-sg" })
}

resource "aws_security_group" "mysql" {
  name        = "${var.name}-mysql-sg"
  description = "MySQL security group"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from app"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-mysql-sg" })
}

resource "aws_security_group" "monitoring" {
  name        = "${var.name}-monitoring-sg"
  description = "Prometheus and Grafana"
  vpc_id      = var.vpc_id

  ingress {
    description = "Prometheus"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description = "Grafana"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-monitoring-sg" })
}
