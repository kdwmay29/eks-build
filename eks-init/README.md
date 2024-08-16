# EKS Fargate

## 시작

aws cli 설치 후 aws configure 설정

---

## 1. VPC, subnet 구성

VPC에 public, private subnet 만들고 igw, nat gateway, routing table 연결

## 2. private subnet에 CLI Server 생성

SSM Session Manager를 통해 접속할 수 있도록 Security Group과 VPC Endpoint 설정  
eksctl과 kubectl을 자동으로 설치 및 세팅하도록 userdata 설정

## 3. eks cluster 생성 - fargate

VPC 내부에서만 api server에 kubectl 날릴 수 있도록 private endpoint만 true로 설정  
coreDNS가 fargate에서 실행되도록 IAM 역할과 설정 추가  
cli server에서 control plane에 접근 가능하도록 control plane에 security group 추가

---

## 이후 실행해야 할 명령어

1. kubeconfig 파일을 ~/.kube/config 경로에 저장 -> EKS 클러스터에 kubectl 명령을 실행 가능

```
aws eks --region <region-code> update-kubeconfig --name <cluster_name>
```

<!--
2. CoreDNS는 Amazon EKS 클러스터의 Amazon EC2 인프라에서 실행되도록 구성되어 있으나 클러스터에 EC2 인스턴스 없으므로 아래 명령 수행하여 fargate 노드에서만 pod 뜨도록 아래 명령 실행 -> CoreDNS 배포를 즉시 재실행

```
kubectl patch deployment coredns \
-n kube-system \
--type json \
-p='[{"op": "remove", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type"}]'
``` -->

---

## terraform 제대로 동작하지 않는 경우

1. cli server에서 init.sh 파일 실행하여 eksctl과 kubectl 설치 및 환경변수 설정

```
chmod +x ./init.sh
./init.sh
```

2. eksctl 이용해 eks cluster 생성

VPC id와 subnet id를 수정한 뒤, new-eks-cluster.yaml 파일을 eksctl로 실행

```
eksctl create cluster -f new-eks-cluster.yaml
```
