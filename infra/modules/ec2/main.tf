resource "aws_instance" "app" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]

  associate_public_ip_address = true  # for dev only
  key_name                     = var.key_name

user_data = <<-EOF
  #!/bin/bash
  apt update -y
  apt install -y docker.io awscli
  systemctl enable docker
  systemctl start docker

  # Fetch Docker Hub creds from AWS SSM
  USERNAME=$(aws ssm get-parameter --name "/dockerhub/username" --region ${var.region} --query "Parameter.Value" --output text)
  TOKEN=$(aws ssm get-parameter --name "/dockerhub/token" --with-decryption --region ${var.region} --query "Parameter.Value" --output text)

  # Login to Docker Hub
  echo $TOKEN | docker login -u $USERNAME --password-stdin

  # Pull and run your private image
  docker pull ${var.image_url}
  docker run -d -p 8090:8090 --name petclinic ${var.image_url}
EOF


  tags = merge(var.tags, {
    Name = "${var.name}-ec2"
  })
}
