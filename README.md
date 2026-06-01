# 🏗️ Team4 Terraform 인프라

> 감정 & 하루 기록 다이어리 서비스의 AWS 인프라를 Terraform으로 관리합니다.
> 

🌐 **서비스 URL**: https://singleuser.cloud

---

## 🏛️ 아키텍처 개요

| 구성요소 | 흐름 |
| --- | --- |
| 사용자 | → Route53 → CloudFront → ALB → EKS Pod |
| EKS Pod | → RDS MySQL (DB 연동) |
| EKS Pod | → S3 (이미지 업로드 / CloudFront로 제공) |
| GitHub | → GitHub Actions → ECR → ArgoCD → EKS 배포 |

### 주요 AWS 리소스

| 리소스 | 상세 |
| --- | --- |
| VPC | 10.0.0.0/16, ap-northeast-2 |
| EKS | v1.30, t3.medium × 2 |
| RDS | MySQL 8.0, db.t3.micro |
| S3 | 이미지 버킷 + Terraform State 버킷 |
| CloudFront | 이미지 CDN |
| Route53 | singleuser.cloud |
| ACM | HTTPS 인증서 |

---

## 📁 디렉터리 구조

| 파일/디렉터리 | 설명 |
| --- | --- |
| `main.tf` | 모듈 호출 및 의존성 정의 |
| `variables.tf` | 루트 변수 선언 |
| `outputs.tf` | 루트 output 정의 |
| `backend.tf` | S3 원격 state 설정 |
| `providers.tf` | AWS Provider 설정 |
| `terraform.tfvars` | 변수값 (git 제외) |
| `modules/vpc/` | VPC, Subnet, NAT Gateway, IGW, Route Table, SG |
| `modules/eks/` | EKS 클러스터, 노드그룹, Access Entry |
| `modules/iam/` | IAM Role (EKS, GitHub Actions, OIDC) |
| `modules/irsa/` | IRSA (ALB Controller, diary-app S3) |
| `modules/rds/` | RDS MySQL, Parameter Group, Subnet Group |
| `modules/ecr/` | ECR 레포지토리 |
| `modules/s3/` | S3 버킷, CloudFront |
| `modules/backend/` | Terraform State S3, DynamoDB Lock |
| `modules/route53/` | Route53 호스팅 영역, A 레코드, ACM 검증 |

---

## 🧩 모듈 설명

### vpc

- VPC (10.0.0.0/16)
- Public Subnet 2개 (AZ별)
- Private Subnet 2개 (AZ별)
- DB Subnet 2개 (AZ별)
- NAT Gateway 2개 (AZ별 고가용성)
- Internet Gateway
- Route Table
- Security Group (ALB, EKS Node, RDS)

### eks

- EKS 클러스터 (v1.30)
- 노드그룹 (t3.medium × 2)
- 팀원 7명 kubectl 접근 권한 (Access Entry)

### iam

- EKS 클러스터 Role
- EKS 노드 Role
- GitHub Actions Role (OIDC 기반)

### irsa

- ALB Controller IRSA Role
- diary-app S3 IRSA Role (이미지 업로드)

### rds

- MySQL 8.0 (db.t3.micro)
- DB Subnet Group
- Parameter Group (utf8mb4)

### s3

- 이미지 저장 버킷 (team4-diary-images)
- CloudFront Distribution (이미지 CDN)
- 퍼블릭 차단 + IRSA/CloudFront만 접근 허용

### backend

- Terraform State S3 버킷
- DynamoDB Lock 테이블

### route53

- singleuser.cloud 호스팅 영역
- ALB A 레코드 (data.aws_lb 자동 참조)
- ACM DNS 검증 레코드

---

## ✅ 사전 요구사항

```bash
# 버전 확인
terraform --version  # >= 1.5.0
aws --version        # >= 2.0.0
kubectl version      # >= 1.28
```

- AWS CLI 설정 완료 (`aws configure`)
- AWS 계정: 194722398200
- 리전: ap-northeast-2

---

## 🚀 시작하기

### 1. 레포지토리 클론

```bash
git clone https://github.com/CLD-05/team4_terraform.git
cd team4_terraform/infra
```

### 2. terraform.tfvars 생성

```hcl
# infra/terraform.tfvars
db_password = "your-db-password"
```

### 3. Terraform 초기화

```bash
terraform init
```

### 4. 플랜 확인

```bash
terraform plan
```

---

## 📋 Apply 순서

> ⚠️ 모듈 간 의존성이 있으므로 반드시 순서대로 apply 해야 합니다.
> 

### 1단계 — 네트워크

```bash
terraform apply -target="module.vpc"
```

### 2단계 — IAM

```bash
terraform apply -target="module.iam"
```

### 3단계 — EKS

```bash
terraform apply -target="module.eks"
```

### 4단계 — RDS, S3, IRSA

```bash
terraform apply -target="module.rds"
terraform apply -target="module.s3"
terraform apply -target="module.irsa"
```

### 5단계 — ECR, Backend

```bash
terraform apply -target="module.ecr"
terraform apply -target="module.backend"
```

### 6단계 — ArgoCD 및 ALB Controller 설치

```bash
# ArgoCD 설치
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# ALB Controller 설치
helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=team4-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller

# ArgoCD Application 배포 (team4_config 레포)
kubectl apply -f argocd/project.yaml
kubectl apply -f argocd/application-prod.yaml

# Secret 생성
kubectl create secret generic diary-app-secret \
  --from-literal=DB_HOST=<rds-endpoint> \
  --from-literal=DB_PASSWORD=<db-password> \
  --from-literal=DB_URL="jdbc:mysql://<rds-endpoint>:3306/diarydb?serverTimezone=Asia/Seoul&characterEncoding=UTF-8" \
  -n diary-app-prod
```

### 7단계 — ALB 생성 확인 후 Route53 연결

```bash
# ALB 생성 확인
aws elbv2 describe-load-balancers \
  --query 'LoadBalancers[?contains(LoadBalancerName,`team4`)].{Name:LoadBalancerName,State:State.Code}' \
  --output table

# ALB active 확인 후 Route53 apply
terraform apply -target="module.route53"
```

---

## 🗑️ 리소스 정리

> ⚠️ 반드시 순서대로 진행해야 합니다. Ingress 먼저 삭제하지 않으면 VPC 삭제가 안 됩니다.
> 

```bash
# 1. ArgoCD sync 중지 (selfHeal 방지)
kubectl patch application diary-app-prod -n argocd \
  --type merge \
  -p '{"spec":{"syncPolicy":{"automated":null}}}'

# 2. Ingress 삭제 (ALB 자동 삭제)
kubectl delete ingress diary-app-ingress -n diary-app-prod

# 3. ALB 삭제 확인
aws elbv2 describe-load-balancers \
  --query 'LoadBalancers[?contains(LoadBalancerName,`team4`)].{Name:LoadBalancerName,State:State.Code}' \
  --output table

# 4. EKS SG 태그 추가 (삭제 권한 확보)
for sg in $(aws ec2 describe-security-groups \
  --filters "Name=vpc-id,Values=<vpc-id>" \
  --query 'SecurityGroups[*].GroupId' --output text); do
  aws ec2 create-tags --resources $sg --tags Key=team,Value=team4
done

# 5. Terraform destroy
terraform destroy
```

---

## 🔧 주요 트러블슈팅

### 1. RDS apply 시 Invalid security group

**원인**: VPC 재생성 후 SG ID가 바뀌었는데 하드코딩된 ID 참조
**해결**: `rds_sg_id = module.vpc.rds_sg_id` 로 변경

### 2. EKS Access Entry 409

**원인**: EKS 클러스터가 살아있어서 access entry 이미 존재
**해결**: `terraform import "module.eks.aws_eks_access_entry.team[N]"` 로 state 등록

### 3. VPC DependencyViolation

**원인**: ALB나 ENI가 VPC에 남아있어서 삭제 불가
**해결**: Ingress 먼저 삭제 후 ALB 삭제 확인 → terraform destroy

### 4. SG 삭제 권한 없음 (403)

**원인**: EKS 자동 생성 SG에 team 태그 없어서 DenyOtherTeamResources 정책에 막힘
**해결**: 삭제 전 모든 SG에 `Key=team, Value=team4` 태그 추가

### 5. Route53 ALB 에러

**원인**: ALB 생성 전 `data "aws_lb"` 참조 시 에러
**해결**: ALB 생성 완료 후 `terraform apply -target="module.route53"` 실행

### 6. Terraform State Lock 손상

**원인**: apply 중단으로 DynamoDB Lock 테이블에 lock 남아있음
**해결**:

```bash
aws dynamodb delete-item \
  --table-name team4-terraform-lock \
  --key '{"LockID": {"S": "team4-terraform-state-team4/vpc/terraform.tfstate"}}'
```

---

## 👥 팀 정보

| 항목 | 내용 |
| --- | --- |
| AWS 계정 | 194722398200 |
| 리전 | ap-northeast-2 |
| 서비스 URL | https://singleuser.cloud |
| EKS 클러스터 | team4-cluster |
| RDS | team4-rds |
| ECR | team4-backend-api |
| S3 State | team4-terraform-state-team4 |
