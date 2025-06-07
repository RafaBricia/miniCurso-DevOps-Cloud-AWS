# Mini Curso DevOps e AWS | Cluster EKS e ALB - Aula 03

---

# Gerenciamento de Cluster EKS na AWS

Este documento explica os principais comandos e configurações necessários para gerenciar um cluster Amazon EKS (Elastic Kubernetes Service) usando Terraform, AWS CLI e kubectl.

## 📌 1. Configuração Inicial (Terraform)

### 1.1. Inicializar o Terraform

```bash
terraform init
```

- Baixa os providers necessários (como hashicorp/aws)
- Prepara o diretório para execução do Terraform

### 1.2. Verificar o plano de execução

```bash
terraform plan
```

- Mostra quais recursos serão criados/modificados sem aplicar as mudanças

### 1.3. Aplicar a infraestrutura

```bash
terraform apply
```

- Cria/atualiza os recursos na AWS (VPC, EKS, NodeGroups, etc.)
- Pode demorar alguns minutos

## 🔧 2. Configuração do AWS CLI e kubectl

### 2.1. Instalar o kubectl

```bash
sudo snap install kubectl --classic
```

- Instala o cliente Kubernetes (kubectl)
- A flag `--classic` é necessária para permissões amplas

### 2.2. Atualizar o kubeconfig para acessar o cluster

```bash
aws eks update-kubeconfig \
  --region us-west-1 \
  --name live-minicurso-deveops-cloud-eks_cluster
```

- Configura o acesso ao cluster EKS no arquivo `~/.kube/config`
- **Problema comum:** Sem permissões → Verificar IAM

### 2.3. Verificar acesso ao cluster

```bash
kubectl get nodes
```

- Se der erro **Forbidden:** O usuário AWS não tem permissão no Kubernetes

## 🔐 3. Gerenciamento de Permissões (IAM + RBAC)

### 3.1. Verificar a Role do NodeGroup

```bash
aws iam get-role --role-name minicurso-deveops-cloud-eks_ng-Role-NEW
```

- Mostra a política de AssumeRole (quem pode usar essa role)

### 3.2. Atualizar a política de AssumeRole

```bash
aws iam update-assume-role-policy \
  --role-name minicurso-deveops-cloud-eks_ng-Role-NEW \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": { "Service": "ec2.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }]
  }'
```

- Permite que instâncias EC2 (nodes do EKS) assumam essa role

### 3.3. Adicionar políticas ao NodeGroup

```bash
# Política para Worker Nodes
aws iam attach-role-policy \
  --role-name minicurso-deveops-cloud-eks_ng-Role-NEW \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy

# Política para CNI (Container Network Interface)
aws iam attach-role-policy \
  --role-name minicurso-deveops-cloud-eks_ng-Role-NEW \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy

# Política para Container Registry (readonly)
aws iam attach-role-policy \
  --role-name minicurso-deveops-cloud-eks_ng-Role-NEW \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
```

- Essas políticas são **obrigatórias** para os Nodes do EKS funcionarem

## 🛠 4. Gerenciamento do Cluster (kubectl)

### 4.1. Mapear um usuário IAM para o RBAC do Kubernetes

```bash
eksctl create iamidentitymapping \
  --cluster live-minicurso-deveops-cloud-eks_cluster \
  --arn arn:aws:iam::516723929672:user/administrador-Rafaela \
  --group system:masters \
  --region us-west-1
```

- Vincula um usuário/role IAM a um grupo RBAC (como `system:masters` para admin)

### 4.2. Verificar ConfigMap aws-auth

```bash
kubectl get configmap aws-auth -n kube-system -o yaml
```

- Mostra os mapeamentos IAM → Kubernetes

### 4.3. Reiniciar os Nodes (se necessário)

```bash
kubectl delete nodes --all
```

- Força o EKS a recriar os Nodes (útil após mudanças de permissão)

## 🚨 5. Solução de Problemas Comuns

### Erro: "User cannot list resource nodes"

**Causa:** Falta de mapeamento IAM → RBAC

**Solução:**
```bash
eksctl create iamidentitymapping ...  # (como na Seção 4.1)
```

### Erro: "is not authorized to perform: sts:AssumeRole"

**Causa:** O usuário não pode assumir a role do EKS

**Solução:**
```bash
aws iam update-assume-role-policy ...  # (como na Seção 3.2)
```

### Erro: "Unable to connect to the server"

**Causa:** Problema no kubeconfig ou credenciais AWS

**Solução:**
```bash
# Verifica credenciais AWS
aws sts get-caller-identity

# Reconfigura o acesso
aws eks update-kubeconfig ...
```

## ✅ Conclusão

- **Terraform:** Gerencia a infraestrutura (EKS, VPC, NodeGroups)
- **AWS CLI:** Configura permissões (IAM, Roles, Policies)
- **kubectl:** Interage com o cluster (pods, nodes, deployments)
- **eksctl:** Facilita o gerenciamento de clusters EKS

### Checklist de Verificação

Se ainda houver problemas, verifique:

- [ ] Permissões IAM do usuário
- [ ] Mapeamento no aws-auth ConfigMap
- [ ] Políticas das Roles associadas ao EKS

---

> **Nota:** Substitua os nomes específicos (cluster, roles, usuários) pelos valores do seu ambiente antes de executar os comandos.