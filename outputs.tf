output "db_address" {
  description = "Hostname do RDS (usado como Host na connection string)"
  value       = aws_db_instance.postgres.address
}

output "db_port" {
  description = "Porta do RDS"
  value       = aws_db_instance.postgres.port
}

output "postgres_connection_string" {
  description = "Connection string para as aplicações rodando dentro do EKS"
  value       = "Host=${aws_db_instance.postgres.address};Port=${aws_db_instance.postgres.port};Database=${var.db_name};Username=${var.db_user};Password=${var.db_password}"
  sensitive   = true
}

output "rds_security_group_id" {
  description = "Security group do RDS — usado por tech-challenge-lambda para liberar acesso da Lambda de autenticação"
  value       = aws_security_group.postgres.id
}
