provider "aws" {
  region = "ap-northeast-2"
}

# RDS 보안 그룹 생성 (Redis와 동일한 서브넷 그룹 사용)
resource "aws_security_group" "rds_sg" {
  name        = "rds_security_group"
  description = "Security group for RDS"
  vpc_id      = module.vpc.vpc_id # RDS 클러스터가 속한 VPC의 ID

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id] # EKS 노드의 보안 그룹을 허용
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # 모든 아웃바운드 트래픽 허용 (필요에 따라 제한 가능)
  }

  tags = {
    Name = "rds-security-group"
  }
}

resource "aws_db_subnet_group" "aurora" {
  name       = "ecom-db-subnet-group"
  subnet_ids = module.vpc.intra_subnets
  tags = {
    Name = "ecom-db-subnet-group"
  }
}

# RDS 클러스터 생성
resource "aws_rds_cluster" "aurora_mysql" {
  cluster_identifier      = "dev-ecom-aurora-cluster"  # 클러스터 이름
  engine                  = "aurora-mysql"             # 엔진 타입 (Aurora MySQL)
  engine_version          = "5.7.mysql_aurora.2.12.0"  # 엔진 버전 (적절한 버전으로 수정 필요)
  master_username         = "admin"                    # 마스터 사용자 이름
  master_password         = "password1234"       # 마스터 사용자 비밀번호 (실제 비밀번호로 변경)
  database_name           = "database1"                # 기본 데이터베이스 이름
  backup_retention_period = 1                          # 백업 보존 기간 (일 단위)
  preferred_backup_window = "07:00-09:00"              # 선호 백업 시간대
  db_subnet_group_name    = aws_db_subnet_group.aurora.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id] # RDS 보안 그룹 설정
  storage_encrypted       = true                       # 스토리지 암호화 활성화
# kms_key_id              = "arn:aws:kms:ap-northeast-3:654654433513:key/f8dc0a45-f1fb-4d89-b8d7-ce27230a77ec" # KMS 키 ARN (실제 ARN으로 변경)

  tags = {
    Name = "dev-ecom-aurora-cluster"
  }
}

# RDS 클러스터 인스턴스 생성
resource "aws_rds_cluster_instance" "aurora_mysql_instance" {
  identifier        = "aurora-mysql-instance-1"        # 인스턴스 식별자
  cluster_identifier = aws_rds_cluster.aurora_mysql.id  # 클러스터 ID와 연결
  instance_class     = "db.r5.large"                   # 인스턴스 클래스 (실제 요구에 맞게 변경)
  engine             = aws_rds_cluster.aurora_mysql.engine
  engine_version     = aws_rds_cluster.aurora_mysql.engine_version
  publicly_accessible = false                           # 퍼블릭 액세스 비활성화
  db_subnet_group_name = aws_db_subnet_group.aurora.name

  tags = {
    Name = "aurora-mysql-instance-1"
  }
}

# 출력: RDS 엔드포인트
output "rds_endpoint" {
  value = aws_rds_cluster.aurora_mysql.endpoint
}
