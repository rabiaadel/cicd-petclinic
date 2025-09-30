resource "aws_instance" "petclinic" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 us-east-1
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private.id
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  tags = { Name = "PetclinicApp" }
}
