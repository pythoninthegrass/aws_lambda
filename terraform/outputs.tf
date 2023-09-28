output "vpc-id" {
  value = aws_vpc.lambda.id
}

output "lambda-subnet" {
  value = aws_subnet.lambda-subnet.id
}

output "lambda-security-group" {
  value = aws_security_group.lambda-sg.id
}
