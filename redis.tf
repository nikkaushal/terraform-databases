
resource "aws_elasticache_subnet_group" "redis" {
  name       = "redis-${var.ENV}"
  subnet_ids = data.terraform_remote_state.vpc.outputs.PRIVATE_SUBNETS
}

resource "aws_elasticache_parameter_group" "default" {
  name   = "redis-pg-${var.ENV}"
  family = "redis5.0"
  }

resource "aws_security_group" "allow-redis" {
  name                    = "allow-redis-${var.ENV}"
  description             = "allow-redis-${var.ENV}"
  vpc_id                  = data.terraform_remote_state.vpc.outputs.VPC_ID

  ingress {
    description           = "SSH"
    from_port             = 6379
    to_port               = 6379
    protocol              = "tcp"
    cidr_blocks           = [data.terraform_remote_state.vpc.outputs.VPC_CIDR]
  }

  egress {
    from_port             = 0
    to_port               = 0
    protocol              = "-1"
    cidr_blocks           = ["0.0.0.0/0"]
  }

  tags = {
    Name                  = "allow-redis-${var.ENV}"
  }
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "redis-${var.ENV}e"
  engine               = "redis"
  node_type            = "cache.t3.small"
  num_cache_nodes      = 1
  parameter_group_name = aws_elasticache_parameter_group.default.name
  engine_version       = "5.0.5"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.redis.name
}

output "redis" {
  value = aws_elasticache_cluster.redis.cache_nodes[0].address
}

//resource "aws_route53_record" "redis" {
//  name        = "redis-${var.ENV}"
//  type        = "CNAME"
//  zone_id     = data.terraform_remote_state.vpc.outputs.ZONE_ID
//  ttl         = "1000"
//  records     = [aws_elasticache_cluster.redis.cluster_address]
//}