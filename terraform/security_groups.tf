# BASTION
resource "aws_security_group" "bastion_ec2_sg" {
  name        = "epam-bastion-ec2-sg"
  description = "Security group for EC2 bastion instances"

  vpc_id = module.network.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "bastion_ingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion_ec2_sg.id
}

resource "aws_security_group_rule" "bastion_https_ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion_ec2_sg.id
}

resource "aws_security_group_rule" "ingress_sg_master_flannel" {
  type              = "ingress"
  from_port         = 8472
  to_port           = 8472
  protocol          = "udp"
  cidr_blocks       = [module.network.vpc_cidr]
  security_group_id = aws_security_group.bastion_ec2_sg.id
}

resource "aws_security_group_rule" "ingress_sg_api" {
  type              = "ingress"
  from_port         = 6443
  to_port           = 6443
  protocol          = "tcp"
  cidr_blocks       = [module.network.vpc_cidr]
  security_group_id = aws_security_group.bastion_ec2_sg.id
}

resource "aws_security_group_rule" "ingress_sg_etcd" {
  type              = "ingress"
  from_port         = 2379
  to_port           = 2379
  protocol          = "tcp"
  cidr_blocks       = [module.network.vpc_cidr]
  security_group_id = aws_security_group.bastion_ec2_sg.id
}

resource "aws_security_group_rule" "ingress_sg_kubelet" {
  type              = "ingress"
  from_port         = 10250
  to_port           = 10250
  protocol          = "tcp"
  cidr_blocks       = [module.network.vpc_cidr]
  security_group_id = aws_security_group.bastion_ec2_sg.id
}

resource "aws_security_group_rule" "ingress_sg_scheduler" {
  type              = "ingress"
  from_port         = 10259
  to_port           = 10259
  protocol          = "tcp"
  cidr_blocks       = [module.network.vpc_cidr]
  security_group_id = aws_security_group.bastion_ec2_sg.id
}

resource "aws_security_group_rule" "ingress_sg_cm" {
  type              = "ingress"
  from_port         = 10257
  to_port           = 10257
  protocol          = "tcp"
  cidr_blocks       = [module.network.vpc_cidr]
  security_group_id = aws_security_group.bastion_ec2_sg.id
}



# WORKER

resource "aws_security_group" "worker_ec2_sg" {
  name        = "epam-worker-ec2-sg"
  description = "Security group for EC2 worker instances"

  vpc_id = module.network.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "worker_ingress" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion_ec2_sg.id
  security_group_id        = aws_security_group.worker_ec2_sg.id
}

# NAT INSTANCE

resource "aws_security_group" "nat_ec2_sg" {
  name        = "epam-nat-ec2-sg"
  description = "Security group for NAT instances"

  vpc_id = module.network.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [module.network.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
