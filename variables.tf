variable "aws_region" {
  description = "Região AWS (decidida no ADR-010)"
  type        = string
  default     = "us-east-1"
}

variable "db_name" {
  description = "Nome do banco de dados principal"
  type        = string
  default     = "oficinamecanica"
}

variable "db_user" {
  description = "Usuário do PostgreSQL"
  type        = string
  default     = "oficina"
}

variable "db_password" {
  description = "Senha do PostgreSQL — obrigatório, não tem default"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "Classe da instância RDS (sizing definido no ADR-010)"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Armazenamento alocado do RDS em GB (mínimo viável)"
  type        = number
  default     = 20
}
