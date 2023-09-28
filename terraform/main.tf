data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_vpc" "lambda" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "lambda-vpc"
  }
}

resource "aws_subnet" "lambda" {
  cidr_block        = "10.0.1.0/24"
  vpc_id            = aws_vpc.lambda.id
  availability_zone = "us-east-1"

  tags = {
    Name = "lambda-subnet"
  }
}

resource "aws_security_group" "lambda" {
  name_prefix = "lambda-sg"
  vpc_id      = aws_vpc.lambda.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lambda-sg"
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  # assume_role_policy = data.aws_iam_policy_document.assume_role.json
  assume_role_policy = file("assume_role.json")
}

resource "aws_iam_role_policy_attachment" "iam_for_lambda" {
  policy_arn = aws_iam_policy.lambda.arn
  role       = aws_iam_role.lambda.name
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda.js"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "test_lambda" {
  function_name    = "lambda_function_name"
  filename          = "lambda_function_payload.zip"
  source_code_hash = filebase64sha256("lambda_function_payload.zip")
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "index.test"

  runtime = "nodejs18.x"

  vpc_config {
    subnet_ids         = [aws_subnet.subnet.id]
    security_group_ids = [aws_security_group.subnet.id]
  }

  environment {
    variables = {
      foo = "bar"
    }
  }
}
