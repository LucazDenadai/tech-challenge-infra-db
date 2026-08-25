# Subnet group do RDS usando as subnets privadas da VPC criada em tech-challenge-infra-k8s
resource "aws_db_subnet_group" "postgres" {
  name       = "oficina-mecanica-rds"
  subnet_ids = data.terraform_remote_state.infra_k8s.outputs.private_subnet_ids
}

# Security group do RDS — libera acesso apenas do security group dos nós EKS,
# não da VPC inteira (mais restrito do que o critério mínimo do CARD-28)
resource "aws_security_group" "postgres" {
  name        = "oficina-mecanica-rds-sg"
  description = "Acesso ao RDS PostgreSQL restrito aos nós do EKS"
  vpc_id      = data.terraform_remote_state.infra_k8s.outputs.vpc_id

  ingress {
    description     = "PostgreSQL a partir dos nos EKS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [data.terraform_remote_state.infra_k8s.outputs.node_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "postgres" {
  identifier     = "oficina-mecanica-db"
  engine         = "postgres"
  engine_version = "16"

  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage

  db_name  = var.db_name
  username = var.db_user
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.postgres.name
  vpc_security_group_ids = [aws_security_group.postgres.id]

  # Uso sob demanda (ADR-010) — sem necessidade de backup automatizado longo nem multi-AZ
  backup_retention_period = 1
  multi_az                = false
  publicly_accessible     = false

  skip_final_snapshot = true
}

# Os schemas "atendimento" e "estoque" (ADR-007) são criados pela aplicação no startup,
# no mesmo bloco que já cria o banco caso não exista (lição registrada no CONTEXT-PROMPT
# sobre o CARD-14) — não pelo Terraform, já que o RDS fica em subnet privada e o
# terraform apply roda fora da VPC (notebook local ou runner ubuntu-latest do GitHub Actions).
