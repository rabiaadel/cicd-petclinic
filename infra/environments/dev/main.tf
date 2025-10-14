provider "aws" {
  region = "us-east-1"
}


module "ecr" {
  source = "../../modules/ecr"
  name   = "petclinic"
  tags = {
    Environment = "dev"
    Project     = "petclinic"
  }
}

module "vpc" {
  source          = "../../modules/vpc"
  name            = "petclinic"
  vpc_cidr        = "10.0.0.0/16"
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  tags = {
    Environment = "dev"
    Project     = "petclinic"
  }
}

module "security" {
  source   = "../../modules/security"
  name     = "petclinic"
  vpc_id   = module.vpc.vpc_id
  vpc_cidr = "10.0.0.0/16"

  tags = {
    Environment = "dev"
    Project     = "petclinic"
  }
}

module "ec2" {
  source            = "../../modules/ec2"
  region            = "us-east-1"
  name              = "petclinic"
  ami_id            = "ami-0c02fb55956c7d316" # Ubuntu 22.04 in us-east-1
  instance_type     = "t2.micro"
  subnet_id         = module.vpc.public_subnets[0]
  security_group_id = module.security.app_sg_id
  key_name          = "my-keypair"        # your existing key pair name
  image_url         = "springcommunity/spring-petclinic"  # or your DockerHub/ECR image

  tags = {
    Environment = "dev"
    Project     = "petclinic"
  }
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "app_sg_id" {
  value = module.security.app_sg_id
}

output "ec2_public_ip" {
  value = module.ec2.public_ip
}