# postech-tc3-infra-k8s

Provisionamento do **cluster Kubernetes (Amazon EKS)** e do **API Gateway** do sistema de gestão de oficinas mecânicas.

Tech Challenge Fase 3 — FIAP Pós Tech SOAT.

## Propósito

Entrega a plataforma onde a aplicação roda: cluster EKS com node group escalável e o HTTP API Gateway que fica na frente dele. O banco vive em [`postech-tc3-infra-database`](https://github.com/Kc1t/postech-tc3-infra-database); a aplicação, em [`postech-tc3-app`](https://github.com/Kc1t/postech-tc3-app); o autorizador, em [`postech-tc3-lambda-auth`](https://github.com/Kc1t/postech-tc3-lambda-auth).

## Tecnologias

- Terraform >= 1.5
- AWS: EKS, API Gateway v2 (HTTP API), CloudWatch Logs
- Backend de state: S3
- CI/CD: GitHub Actions com OIDC

## Arquitetura

```
   Cliente
      │
      ▼
 ┌─────────────────┐   authorizer (REQUEST)   ┌──────────────────┐
 │  API Gateway    │─────────────────────────▶│  Lambda auth CPF │
 │  (HTTP API)     │◀──── allow + contexto ───│  (outro repo)    │
 └────────┬────────┘                          └──────────────────┘
          │ rota autorizada
          ▼
 ┌─────────────────────────────────┐
 │  EKS  ── node group (min..max)  │────▶ RDS (infra-database)
 │        ── HPA por CPU/memória   │
 └─────────────────────────────────┘
```

## Estrutura

```
versions.tf      providers e backend
variables.tf     entradas
main.tf          locals e lookup de subnets
eks.tf           cluster + managed node group
api_gateway.tf   HTTP API, stage, access log e authorizer
outputs.tf       endpoint do cluster, id do gateway, comando de kubeconfig
envs/            tfvars por ambiente
```

## Execução local

```bash
terraform init \
  -backend-config="bucket=<seu-bucket-de-state>" \
  -backend-config="key=k8s/staging.tfstate" \
  -backend-config="region=us-east-1"

terraform plan  -var-file=envs/staging.tfvars
terraform apply -var-file=envs/staging.tfvars

aws eks update-kubeconfig --region us-east-1 --name postech-tc3-staging
```

O `lambda_authorizer_invoke_arn` é opcional: sem ele o authorizer não é criado, o que permite subir o gateway antes da lambda existir.

## Deploy

| Evento | Ação |
|---|---|
| Pull Request | `fmt`, `validate`, `tfsec` e `plan` em staging |
| Push em `homolog` | `apply` em staging |
| Push em `main` | `apply` em produção |

Secrets necessários: `AWS_ROLE_ARN` e `TF_STATE_BUCKET`.

## Escalabilidade

- **Nós:** managed node group entre `node_min` e `node_max`.
- **Pods:** HPA declarado nos manifests do `postech-tc3-app`.
