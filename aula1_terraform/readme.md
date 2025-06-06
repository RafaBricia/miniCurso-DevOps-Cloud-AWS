#Mini Curso DevOps e AWS | Terraform - Aula 01

🔗 [Assista à Aula no YouTube](https://www.youtube.com/watch?v=DNiXLs8q2L0)

Este projeto demonstra a criação de uma infraestrutura AWS usando Terraform, com foco em mensageria e gerenciamento de estado remoto. Ele configura uma fila SQS para comunicação assíncrona entre serviços, além de implementar um backend remoto para o Terraform utilizando um bucket S3 para armazenar o estado e uma tabela DynamoDB para controle de concorrência (lock) do estado.

---


## ⚙️ Pré-requisitos

Antes de rodar o Terraform, garanta que:

1. **Terraform está instalado e configurado**

   - Instalação: https://learn.hashicorp.com/tutorials/terraform/install-cli  
   - Verifique com:  
     ```bash
     terraform version
     ```

2. **AWS CLI está instalado e configurado**

   - Instalação: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html  
   - Configure as credenciais com:  
     ```bash
     aws configure
     ```
   - Insira sua Access Key, Secret Access Key, região e formato padrão.

3. **Configuração do backend remoto**

   - A pasta `remote-backend-stack` contém recursos para armazenar o estado remoto do Terraform:
     - Bucket S3 para armazenar o arquivo de estado
     - Tabela DynamoDB para controle de lock (evita conflitos em alterações simultâneas)

---

## 🚀 Comandos básicos para rodar o projeto

Na pasta `remote-backend-stack`, configure o backend e execute:

```bash
terraform init          # Inicializa o Terraform e configura o backend remoto
terraform validate      # Valida a sintaxe dos arquivos Terraform
terraform apply         # Aplica a infraestrutura definida
terraform destroy       # Remove a infraestrutura criada
```

Depois, na pasta `main-stack`, execute:

```bash
terraform init          # Inicializa o Terraform usando o backend remoto configurado
terraform validate
terraform apply
terraform destroy
```

---

## 📦 O que foi criado na AWS

### Na pasta `remote-backend-stack`

- **S3 Bucket:**  
  Armazena o arquivo `terraform.tfstate` para manter o estado remoto do Terraform.

- **DynamoDB Table:**  
  Usada para lock do estado, evitando múltiplas alterações simultâneas no estado do Terraform.

---

### Na pasta `main-stack`

- **SQS Queue:**  
  Criação de uma fila SQS para mensagens assíncronas.

- Outros recursos descritos nos arquivos `main.tf` e `variables.tf` do `main-stack`.

---

## 💰 Custos dos recursos

### Recursos Gratuitos

- **SQS (Simple Queue Service):**  
  - Até 1 milhão de solicitações por mês são gratuitas.

- **DynamoDB:**  
  - Até 25 GB de armazenamento gratuito, com capacidade de leitura/gravação limitada.

- **S3 (Simple Storage Service):**  
  - Até 5 GB de armazenamento padrão gratuito por mês.

### Recursos que podem gerar custos

- Se ultrapassar os limites gratuitos acima, você será cobrado conforme a tabela da AWS.  
- Exemplo:  
  - Uso excessivo de SQS além do gratuito.  
  - Tabela DynamoDB com alta capacidade provisionada.  
  - Bucket S3 com alto volume de dados armazenados ou transferências.

---

## ⚠️ Dicas importantes

- Sempre revise seu arquivo `.gitignore` para evitar subir arquivos sensíveis, como `terraform.tfstate` e credenciais.
- Use `terraform destroy` para apagar recursos e evitar cobranças inesperadas.
- Monitore sua conta AWS para evitar custos não planejados.

---


## 📋 Estrutura do Projeto

```
├── main-stack
│   ├── main.tf
│   ├── output.tf
│   ├── sqs.queue.tf
│   └── variables.tf
└── remote-backend-stack
    ├── dynamo.table.tf
    ├── main.tf
    ├── output.tf
    ├── s3.bucket.tf
    ├── terraform.tfstate
    ├── terraform.tfstate.backup
    └── variables.tf
```

- **main-stack:** Contém a infraestrutura principal, incluindo recursos SQS.
- **remote-backend-stack:** Configuração do backend remoto para Terraform, usando S3 e DynamoDB para o lock do estado.

---

## 📌 Observações

- Esse projeto foi feito para fins educacionais.
- Sempre revise os recursos que você está criando para evitar cobranças desnecessárias.
- Para consultar os limites do Free Tier da AWS: https://aws.amazon.com/free/
