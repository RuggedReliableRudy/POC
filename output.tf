ecs_subnet_ids = module.network.ecs_private_subnets
db_subnet_ids  = module.network.rds_private_subnets


{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws-us-gov:iam::018743596699:oidc-provider/va.ghe.com/_services/token"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "va.ghe.com/_services/token:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "va.ghe.com/_services/token:sub": "repo:software/Project-Accumulator:*"
        }
      }
    }
  ]
}
