# 🛠️ Guia Completo de Solução de Problemas - Cluster EKS com kubectl

## 📍 Contexto Geral

Este guia consolida os principais problemas, diagnósticos e soluções encontrados durante o gerenciamento de clusters Amazon EKS, especialmente relacionados a problemas de autenticação e autorização. Durante a aula 3 do minicurso de DevOps Cloud, foi provisionado um cluster EKS via Terraform, mas diversos problemas de acesso foram encontrados após a configuração inicial.

---

## 🔧 1. Configuração Inicial do Ambiente

### 1.1. Terraform - Provisionamento da Infraestrutura

```bash
# Inicializar o Terraform
terraform init

# Verificar o plano de execução
terraform plan

# Aplicar a infraestrutura
terraform apply
```

**Contexto:** Após o `terraform apply` ser executado com sucesso, é necessário configurar o acesso ao cluster EKS.

### 1.2. Configuração do kubectl

```bash
# Instalar o kubectl (se necessário)
sudo snap install kubectl --classic

# Configurar o acesso ao cluster EKS
aws eks update-kubeconfig --region us-west-1 --name live-minicurso-deveops-cloud-eks_cluster
```

**Resultado esperado:** O comando deve atualizar corretamente o contexto no arquivo `~/.kube/config`.

---

## ❗ 2. Principais Problemas Encontrados

### 2.1. Erro de Autenticação Principal

**Erro:**
```
error: You must be logged in to the server (the server has asked for the client to provide credentials)
```

**Comandos que apresentam o erro:**
- `kubectl get nodes`
- `kubectl edit configmap aws-auth -n kube-system`
- Qualquer comando kubectl que requeira acesso ao cluster

### 2.2. Erro de Permissão para AssumeRole

**Erro:**
```
An error occurred (AccessDenied) when calling the AssumeRole operation: 
User: arn:aws:iam::516723929672:user/administrador-Rafaela is not authorized to perform: sts:AssumeRole
```

### 2.3. Erro no eksctl

**Erro:**
```
Error: getting list of API resources for raw REST client: the server has asked for the client to provide credentials
```

**Comando que falha:**
```bash
eksctl create iamidentitymapping \
  --cluster live-minicurso-deveops-cloud-eks_cluster \
  --region us-west-1 \
  --arn arn:aws:iam::516723929672:user/administrador-Rafaela \
  --username rafaela \
  --group system:masters
```

### 2.4. Erro de Recurso Terraform Não Declarado

**Erro:**
```
A managed resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" has not been declared
```

**Solução:** Corrigido ao declarar corretamente o recurso no arquivo `.tf`.

---

## 🔍 3. Diagnóstico Passo a Passo

### 3.1. Verificação do Contexto Kubernetes

```bash
kubectl config current-context
```

**Resultado esperado:**
```
arn:aws:eks:us-west-1:516723929672:cluster/live-minicurso-deveops-cloud-eks_cluster
```

### 3.2. Verificação da Autenticação AWS

```bash
aws sts get-caller-identity
```

**Resultado esperado:** Confirmação de que o usuário `administrador-Rafaela` está autenticado.

### 3.3. Verificação da Role do NodeGroup

```bash
aws iam get-role --role-name minicurso-deveops-cloud-eks_ng-Role-NEW
```

### 3.4. Verificação do ConfigMap aws-auth

```bash
kubectl get configmap aws-auth -n kube-system -o yaml
```

**Problema:** Este comando também falhará se não houver permissões adequadas.

---

## ✅ 4. Soluções Detalhadas

### 4.1. Corrigir Permissões IAM do Usuário

**Adicionar política de AssumeRole ao usuário:**

```json
{
  "Effect": "Allow",
  "Action": "sts:AssumeRole",
  "Resource": "arn:aws:iam::516723929672:role/minicurso-deveops-cloud-eks-Role"
}
```

### 4.2. Configurar Política de AssumeRole para NodeGroup

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

### 4.3. Adicionar Políticas Obrigatórias ao NodeGroup

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

### 4.4. Mapear Usuário IAM para RBAC do Kubernetes

```bash
eksctl create iamidentitymapping \
  --cluster live-minicurso-deveops-cloud-eks_cluster \
  --arn arn:aws:iam::516723929672:user/administrador-Rafaela \
  --group system:masters \
  --region us-west-1
```

**Importante:** Este comando só funcionará depois de resolver os problemas de permissão IAM.

### 4.5. Alternativa de Emergência via Console AWS

**Quando os comandos não funcionam:**
1. Acesse o Console da AWS como usuário root ou administrador
2. Navegue até EKS > Clusters > seu-cluster > Configuration > Compute
3. Edite manualmente o ConfigMap `aws-auth` para adicionar o usuário
4. Ou atribua as permissões necessárias via IAM Console

---

## 🚨 5. Problemas Comuns e Suas Soluções

### 5.1. "User cannot list resource nodes"

**Causa:** Falta de mapeamento IAM → RBAC
**Solução:** Executar `eksctl create iamidentitymapping` após corrigir permissões

### 5.2. "Unable to connect to the server"

**Causa:** Problema no kubeconfig ou credenciais AWS
**Soluções:**
```bash
# Verificar credenciais
aws sts get-caller-identity

# Reconfigurar acesso
aws eks update-kubeconfig --region us-west-1 --name nome-do-cluster
```

### 5.3. "The server has asked for the client to provide credentials"

**Causa:** O usuário IAM não está mapeado no ConfigMap aws-auth do Kubernetes
**Soluções:**
1. Mapear via eksctl (se possível)
2. Editar manualmente via Console AWS
3. Usar usuário root temporariamente para configurar permissões

### 5.4. Nodes não aparecem ou ficam NotReady

**Solução:**
```bash
# Reiniciar os nodes (se necessário)
kubectl delete nodes --all
```

---

## 🔐 6. Entendimento do Problema Principal

### O que estava acontecendo:

O usuário IAM (`administrador-Rafaela`) não tinha permissão para:
- Acessar o cluster via kubectl
- Assumir a role (AssumeRole) associada ao cluster EKS  
- Ver ou editar o configmap/aws-auth, onde acontece o mapeamento de usuários e roles IAM para permissões no cluster

### Solução implementada via Console AWS:

Geralmente se resolve através de:
- Atribuição de permissões `eks:Access` e `sts:AssumeRole` ao usuário
- Adição do usuário ao aws-auth manualmente
- Configuração correta do `eksctl create iamidentitymapping` após ajustar permissões

---

## 📌 7. Boas Práticas e Dicas

### 7.1. Configuração Inicial
- Sempre garanta que o primeiro usuário/role que cria o cluster tenha permissão explícita no aws-auth
- Este usuário/role terá acesso inicial ao Kubernetes

### 7.2. Checklist de Verificação

Antes de considerar o problema resolvido, verifique:
- [ ] Permissões IAM do usuário estão corretas
- [ ] Mapeamento no aws-auth ConfigMap está configurado
- [ ] Políticas das Roles associadas ao EKS estão anexadas
- [ ] Comando `kubectl get nodes` funciona sem erro
- [ ] Comando `aws sts get-caller-identity` retorna o usuário correto

### 7.3. Fluxo de Comandos para Teste

```bash
# 1. Verificar identidade AWS
aws sts get-caller-identity

# 2. Verificar contexto kubectl
kubectl config current-context

# 3. Testar acesso básico
kubectl get nodes

# 4. Se falhar, verificar mapeamento
kubectl get configmap aws-auth -n kube-system -o yaml

# 5. Se necessário, mapear usuário
eksctl create iamidentitymapping \
  --cluster NOME_DO_CLUSTER \
  --arn ARN_DO_USUARIO \
  --group system:masters \
  --region REGIAO
```

---

## ✅ Status Final e Ferramentas Utilizadas

**Após correções implementadas:**
- Terraform executou corretamente
- Estrutura da VPC, subnets e roles criada/mantida com sucesso
- Acesso ao cluster EKS funcionando normalmente

**Ferramentas e suas funções:**
- **Terraform:** Gerencia a infraestrutura (EKS, VPC, NodeGroups)
- **AWS CLI:** Configura permissões (IAM, Roles, Policies)  
- **kubectl:** Interage com o cluster (pods, nodes, deployments)
- **eksctl:** Facilita o gerenciamento de clusters EKS

---

> **⚠️ Nota Importante:** Substitua os nomes específicos (cluster, roles, usuários, região) pelos valores do seu ambiente antes de executar os comandos. Os exemplos neste guia usam valores específicos do ambiente de teste mencionado.