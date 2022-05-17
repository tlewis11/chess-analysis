data "aws_acm_certificate" "chess_cert" {
  domain   = "analyzeyourchessgames.com"
}

# TODO: vpc.tf

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_route_table" "public_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }

  tags = {
    Name = "public"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "public-1"
  }
}

resource "aws_subnet" "secondary" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "public-2"
  }
}

resource "aws_route_table_association" "rt_association_a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.public_table.id
}
resource "aws_route_table_association" "rt_association_b" {
  subnet_id      = aws_subnet.secondary.id
  route_table_id = aws_route_table.public_table.id
}


#TODO: load_balancer.tf
resource "aws_security_group" "load_balancer_sg" {
  name        = "analyzeyourchessgames"
  description = "for alb of analyzeyourchessgames.com"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_lb" "chess_engine_alb" {
  name               = "analyzeyourchessgames"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer_sg.id]
  subnets            = [aws_subnet.main.id, aws_subnet.secondary.id]

  tags = {
    Environment = "production"
  }
}

resource "aws_ecs_cluster" "chess_cluster" {
  name = "chess-analysis"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_lb_target_group" "engine_tg" {
  name        = "chess-engine-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

}

resource "aws_lb_listener" "default_listener" {
  load_balancer_arn = aws_lb.chess_engine_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.engine_tg.arn
  }
}

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.chess_engine_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   =  data.aws_acm_certificate.chess_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.engine_tg.arn
  }
}

#ecs_service.tf =======================================

resource "aws_security_group" "ecs_service_sg" {
  name        = "stockfish-engine"
  description = "applied to stockfish-engine ecs tasks"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 5000
    to_port          = 5000
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_ecs_task_definition" "engine_taskdef" {
  family = "stockfish-engine"
  requires_compatibilities = ["FARGATE"]
  network_mode  = "awsvpc"
  cpu = 1024
  memory    = 2048
  execution_role_arn       = aws_iam_role.ecs_service_role.arn


  container_definitions = jsonencode(
  [
    {
      name      = "stockfish-engine"
      image     = aws_ecr_repository.engine_ecr_repo.repository_url
      cpu       = 1024
      memory    = 2048
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]
      logConfiguration = {
        logdriver = "awslogs"
        options = {
          awslogs-group = aws_cloudwatch_log_group.ecs_service_log_group.name,
          awslogs-region = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_cloudwatch_log_group" "ecs_service_log_group" {
  name = "stockfish-engine-ecs-service-logs"
}

resource "aws_iam_policy" "ecs_policy" {
  name = "chess-engine-ecs-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["*"]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role" "ecs_service_role" {
  managed_policy_arns = [aws_iam_policy.ecs_policy.arn]
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = ["ecs.amazonaws.com","ecs-tasks.amazonaws.com"]
        }
      },
    ]
  })
}

resource "aws_ecs_service" "engine_service" {
  depends_on      = [aws_iam_role.ecs_service_role]
  launch_type     = "FARGATE"
  name            = "stockfish-engine"
  cluster         = aws_ecs_cluster.chess_cluster.name
  task_definition =  aws_ecs_task_definition.engine_taskdef.arn
  desired_count   = 1
  #iam_role        = aws_iam_role.ecs_service_role.name

  load_balancer {
    target_group_arn = aws_lb_target_group.engine_tg.arn
    container_name   = "stockfish-engine"
    container_port   = 5000
  }

  network_configuration {
    subnets            = [aws_subnet.main.id, aws_subnet.secondary.id]
    assign_public_ip = true
    security_groups = [aws_security_group.ecs_service_sg.id]
  }
}

resource "aws_ecr_repository" "engine_ecr_repo" {
  name                 = "stockfish-engine"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
