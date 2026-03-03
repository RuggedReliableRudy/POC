ecs_subnet_ids = module.network.ecs_private_subnets
db_subnet_ids  = module.network.rds_private_subnets


{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws-us-gov:iam::018743596699:oidc-provider/token.actions.va.ghe.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.va.ghe.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.va.ghe.com:sub": "repo:software/Project-Accumulator:*"
        }
      }
    }
  ]
}

