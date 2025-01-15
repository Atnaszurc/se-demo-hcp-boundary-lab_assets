# Windows Target

resource "aws_instance" "http-target" {
  ami           = "ami-0f436e50b9fe7144f"
  instance_type = "t3.small"

  key_name               = aws_key_pair.boundary_ec2_keys.key_name
  monitoring             = true
  subnet_id              = data.terraform_remote_state.boundary_demo_init.outputs.priv_subnet_id
  vpc_security_group_ids = [module.http-sec-group.security_group_id]
  tags = {
    Team = "IT"
    Name = "http-target"
  }
}

module "http-sec-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.1"

  name        = "http-sec-group"
  description = "Allow Access from Boundary Worker and Vault to HTTP target"
  vpc_id      = data.terraform_remote_state.boundary_demo_init.outputs.vpc_id
  ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.worker-sec-group.security_group_id
    },
    {
      rule                     = "all-all"
      source_security_group_id = data.terraform_remote_state.boundary_demo_init.outputs.vault_sec_group
    },
  ]
}
