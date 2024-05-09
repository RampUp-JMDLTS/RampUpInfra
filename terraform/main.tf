module "network" {
  source = "./modules/network"

  vpc_cidr = "10.0.0.0/16"

  public_subnets = [
    {
      name       = "frontend1"
      zone       = "us-east-1a"
      cidr_range = "10.0.1.0/24"
    },
    {
      name       = "frontend2"
      zone       = "us-east-1b"
      cidr_range = "10.0.2.0/24"
    },
    {
      name       = "bastion"
      zone       = "us-east-1a"
      cidr_range = "10.0.3.0/24"
    }
  ]

  private_subnets = [
    {
      name       = "backend1"
      zone       = "us-east-1c"
      cidr_range = "10.0.4.0/24"
    },
    {
      name       = "backend2"
      zone       = "us-east-1d"
      cidr_range = "10.0.5.0/24"
    },
    {
      name       = "db"
      zone       = "us-east-1e"
      cidr_range = "10.0.6.0/24"
    },

  ]
}

module "database" {
  source = "./modules/db"

  db_instance_identifier  = "epam-db-instance"
  db_name                 = "epam_db"
  db_username             = "db_admin"
  db_engine               = "mysql"
  db_engine_version       = "5.7"
  db_instance_class       = "db.t3.micro"
  db_allocated_storage    = 10
  db_parameter_group_name = "default.mysql5.7"

  subnet_ids = [
    module.network.private_subnets["db"].id,
    module.network.private_subnets["backend2"].id # this one is because it needs at leat 2 subnets
  ]
}

# ACCESS VIA SSM

resource "aws_iam_role" "ssm_iam_role" {
  name        = "ssm-role"
  description = "Role for access to Bastion via ssm instance"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ssm_iam_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ssm_iam_role.name
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ssm_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

## SSH CONFIG

## Generate PEM (and OpenSSH) formatted private key.
resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits = 4096
}

## Create the file for Public Key
resource "local_file" "public_key" {
  depends_on = [ tls_private_key.key_pair]
  content = tls_private_key.key_pair.public_key_openssh
  filename = var.public_key_path
}

## Create the sensitive file for Private Key
resource "local_sensitive_file" "private_key" {
  depends_on = [ tls_private_key.key_pair ]
  content = tls_private_key.key_pair.private_key_pem
  filename = var.private_key_path
  file_permission = "0600"
}

## AWS SSH Key Pair
resource "aws_key_pair" "key_pair" {
  depends_on = [ local_file.public_key ]
  key_name = "epam-key-pair"
  public_key = tls_private_key.key_pair.public_key_openssh
}

module "vms" {
  source = "./modules/vms"

  allvms = [
    {
      name           = "frontend1"
      instance_type  = "t2.micro"
      subnet_id      = module.network.public_subnets["frontend1"].id
      security_group = aws_security_group.worker_ec2_sg.id
      key_name = aws_key_pair.key_pair.key_name
    },
    {
      name           = "frontend2"
      instance_type  = "t2.micro"
      subnet_id      = module.network.public_subnets["frontend2"].id
      security_group = aws_security_group.worker_ec2_sg.id
      key_name = aws_key_pair.key_pair.key_name
    },
    {
      name                 = "bastion"
      instance_type        = "t2.micro"
      subnet_id            = module.network.public_subnets["bastion"].id
      security_group       = aws_security_group.bastion_ec2_sg.id
      iam_instance_profile = aws_iam_instance_profile.ssm_iam_profile.name
      public_ipv4          = true
      key_name = aws_key_pair.key_pair.key_name
    },
    {
      name           = "backend1"
      instance_type  = "t2.micro"
      subnet_id      = module.network.private_subnets["backend1"].id
      security_group = aws_security_group.worker_ec2_sg.id
      key_name = aws_key_pair.key_pair.key_name
    },
    {
      name           = "backend2"
      instance_type  = "t2.micro"
      subnet_id      = module.network.private_subnets["backend2"].id
      security_group = aws_security_group.worker_ec2_sg.id
      key_name = aws_key_pair.key_pair.key_name
    },
    {
      name              = "nat"
      instance_type     = "t2.micro"
      subnet_id         = module.network.public_subnets["bastion"].id
      security_group    = aws_security_group.nat_ec2_sg.id
      source_dest_check = false
    }
  ]
}

resource "aws_route" "route_nat" {
  route_table_id         = module.network.private_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = module.vms.vms["nat"].primary_network_interface_id
}



