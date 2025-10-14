output "app_sg_id" {
  value = aws_security_group.app.id
}

output "mysql_sg_id" {
  value = aws_security_group.mysql.id
}

output "monitoring_sg_id" {
  value = aws_security_group.monitoring.id
}
