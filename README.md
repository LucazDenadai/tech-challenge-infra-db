# tech-challenge-infra-db

Terraform que provisiona o banco de dados PostgreSQL usado pelo [Tech-challenge](https://github.com/LucazDenadai/Tech-challenge) (Atendimento + Estoque).

Documentação arquitetural completa (ADRs, RFCs, diagramas) em [tech-challenge-docs](https://github.com/LucazDenadai/tech-challenge-docs).

## Estado atual

Provisiona um container **PostgreSQL via Docker**, conectado à rede criada pelo cluster Kind do repositório [tech-challenge-infra-k8s](https://github.com/LucazDenadai/tech-challenge-infra-k8s) — herdado do ADR-005 da Fase 2. A migração para **Amazon RDS** (requisito da Fase 3, ver [ADR-009](https://github.com/LucazDenadai/tech-challenge-docs/blob/main/adr/ADR-009-migracao-aws-e-separacao-repositorios.md)) está prevista no [CARD-28](https://github.com/LucazDenadai/tech-challenge-docs/blob/main/cards/05-fase3-aws/CARD-28-infra-aws-terraform.md).

## Dependência

Este repositório deve ser aplicado **depois** de [tech-challenge-infra-k8s](https://github.com/LucazDenadai/tech-challenge-infra-k8s) — o container PostgreSQL se conecta à rede Docker `kind` criada por aquele cluster.

## O que é criado

| Recurso | Tipo | Descrição |
|---|---|---|
| Container `oficina-postgres` | Docker Container | PostgreSQL 16 com schemas `atendimento` e `estoque` |

## Limitação de plataforma

O provisionamento usa um `local-exec` com **PowerShell** para aguardar o PostgreSQL inicializar e criar os schemas após o `terraform apply`. Por isso, **este Terraform só pode ser executado em Windows**. Em um cenário produtivo, o provisionador seria reescrito com `bash` ou substituído por um recurso nativo (ex: provider `postgresql`).

## Pré-requisitos

- [Docker](https://docs.docker.com/get-docker/) rodando
- [Terraform >= 1.6](https://developer.hashicorp.com/terraform/install)
- Rede Docker `kind` já criada (aplicar `tech-challenge-infra-k8s` primeiro)

## Como usar

```bash
cp terraform.tfvars.example terraform.tfvars
# Edite terraform.tfvars e defina db_password

terraform init
terraform plan
terraform apply
```

Após o apply, veja os valores sensíveis:

```bash
terraform output postgres_connection_string
terraform output postgres_host_connection_string
```

Para destruir:

```bash
terraform destroy
```

## Outputs

| Output | Descrição |
|---|---|
| `container_name` | Nome do container PostgreSQL |
| `postgres_connection_string` | Connection string para pods dentro do cluster |
| `postgres_host_connection_string` | Connection string para acesso pelo host |

## O que NÃO commitar

| Arquivo/Pasta | Motivo |
|---|---|
| `terraform.tfvars` | Contém senhas reais |
| `terraform.tfstate` / `.backup` | Estado da infra, pode conter dados sensíveis |
| `.terraform/` | Cache de providers |

Todos já estão no `.gitignore`.
