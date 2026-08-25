# tech-challenge-infra-db

Terraform que provisiona o banco de dados usado pelo [Tech-challenge](https://github.com/LucazDenadai/Tech-challenge) (Atendimento + Estoque).

Documentação arquitetural completa (ADRs, RFCs, diagramas) em [tech-challenge-docs](https://github.com/LucazDenadai/tech-challenge-docs).

## Estado atual

Provisiona uma instância **RDS PostgreSQL** real (migração do container Docker local do ADR-005, conforme [ADR-009](https://github.com/LucazDenadai/tech-challenge-docs/blob/main/adr/ADR-009-migracao-aws-e-separacao-repositorios.md) e [ADR-010](https://github.com/LucazDenadai/tech-challenge-docs/blob/main/adr/ADR-010-sizing-e-regiao-aws.md)). Ver critérios de aceite em [CARD-28](https://github.com/LucazDenadai/tech-challenge-docs/blob/main/cards/05-fase3-aws/CARD-28-infra-aws-terraform.md).

Depende do state remoto de [tech-challenge-infra-k8s](https://github.com/LucazDenadai/tech-challenge-infra-k8s) (VPC e security group dos nós EKS) — rode o `apply` de lá primeiro.

## O que é criado

| Recurso | Tipo | Descrição |
|---|---|---|
| Instância RDS | `aws_db_instance` | PostgreSQL 16, `db.t3.micro` (sizing do ADR-010) |
| Subnet group | `aws_db_subnet_group` | Usa as subnets privadas da VPC do `infra-k8s` |
| Security group | `aws_security_group` | Libera porta 5432 apenas para o security group dos nós EKS — sem acesso público |

## Schemas `atendimento` e `estoque`

**Não são criados pelo Terraform.** O RDS fica em subnet privada (sem acesso público), e o `terraform apply` roda fora da VPC (notebook local ou runner `ubuntu-latest` do GitHub Actions) — não haveria como o provider `postgresql` conectar para criá-los.

Os schemas são criados pela própria aplicação no startup, no mesmo padrão já usado no CARD-14 para criar o banco automaticamente antes do `MigrateAsync()` (ver lição registrada no `CONTEXT-PROMPT.md` do repositório `Tech-challenge`).

## Pré-requisitos

- Conta AWS com bootstrap já feito (bucket S3 + DynamoDB de state, OIDC/IAM — ver [ADR-011](https://github.com/LucazDenadai/tech-challenge-docs/blob/main/adr/ADR-011-bootstrap-aws-backend-remoto-oidc.md))
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) configurado (`aws configure`)
- [Terraform >= 1.6](https://developer.hashicorp.com/terraform/install)
- `terraform apply` do `tech-challenge-infra-k8s` já executado (fornece VPC e security group)

## Como usar

```bash
cp terraform.tfvars.example terraform.tfvars
# edite terraform.tfvars e defina uma senha real em db_password

terraform init
terraform plan
terraform apply
```

**Lembrete de custo (ADR-010/ADR-011):** este ambiente é provisionado sob demanda, não 24/7. Rode `terraform destroy` ao final de cada sessão de trabalho.

```bash
terraform destroy
```

## Outputs

| Output | Descrição |
|---|---|
| `db_address` | Hostname do RDS |
| `db_port` | Porta do RDS |
| `postgres_connection_string` | Connection string completa (sensitive) |

## O que NÃO commitar

| Arquivo/Pasta | Motivo |
|---|---|
| `terraform.tfvars` | Contém a senha do banco |
| `terraform.tfstate` / `.backup` | Não se aplica — state fica remoto no S3 (ver `versions.tf`) |
| `.terraform/` | Cache de providers |

Todos já estão no `.gitignore`.
