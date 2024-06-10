data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.4.20240429.0-kernel-6.1-x86_64"]
  }
}

resource "aws_instance" "ec2" {
  for_each = { for vm in var.allvms : vm.name => vm }

  ami                         = data.aws_ami.amazon-linux-2.id
  instance_type               = each.value.instance_type
  associate_public_ip_address = each.value.public_ipv4 != null ? each.value.public_ipv4 : false

  subnet_id = each.value.subnet_id

  vpc_security_group_ids = [each.value.security_group]

  iam_instance_profile = each.value.iam_instance_profile != null ? each.value.iam_instance_profile : null

  source_dest_check = each.value.source_dest_check != null ? each.value.source_dest_check : true

  key_name = each.value.key_name != null ? each.value.key_name : null

  user_data                   = each.value.user_data != null ? each.value.user_data : null
  user_data_replace_on_change = true

  tags = {
    Name = "epam_ec2_instance_${each.key}"
    Role = "${each.value.role != null ? each.value.role : "none"}"
  }
}