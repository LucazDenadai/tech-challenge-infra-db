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

variable "db_port" {
  description = "Porta do PostgreSQL exposta no host"
  type        = number
  default     = 5433
}

variable "kind_network" {
  description = "Nome da rede Docker criada pelo cluster Kind (repositório tech-challenge-infra-k8s)"
  type        = string
  default     = "kind"
}
