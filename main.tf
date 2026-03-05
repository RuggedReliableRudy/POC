AWSTemplateFormatVersion: 2010-09-09
Description: QA environment referencing shared IAM roles created in dev

Parameters:
  ProjectName:
    Type: String
    Default: qa-accumulator
    Description: Project prefix (not used for IAM roles in QA)

Resources:

  ###############################################
  # ECS Task Execution Role (Shared with Dev)
  ###############################################
  ECSTaskExecutionRole:
    Type: AWS::IAM::Role
    Properties:
      RoleName: project-cpeload-ecs-task-execution-role
      Path: /project/
      PermissionsBoundary: arn:aws-us-gov:iam::018743596699:policy/vaec/vaec-administrator
      AssumeRolePolicyDocument:
        Version: 2012-10-17
        Statement:
          - Effect: Allow
            Principal:
              Service: ecs-tasks.amazonaws.com
            Action: sts:AssumeRole
      ManagedPolicyArns:
        - arn:aws-us-gov:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy

  ###############################################
  # ECS Task Role (Shared with Dev)
  ###############################################
  ECSTaskRole:
    Type: AWS::IAM::Role
    Properties:
      RoleName: project-cpeload-ecs-task-role
      Path: /project/
      PermissionsBoundary: arn:aws-us-gov:iam::018743596699:policy/vaec/vaec-administrator
      AssumeRolePolicyDocument:
        Version: 2012-10-17
        Statement:
          - Effect: Allow
            Principal:
              Service: ecs-tasks.amazonaws.com
            Action: sts:AssumeRole
      Policies:
        - PolicyName: project-cpeload-ecs-s3-access
          PolicyDocument:
            Version: 2012-10-17
            Statement:
              - Effect: Allow
                Action:
                  - s3:GetObject
                  - s3:ListBucket
                Resource:
                  - arn:aws-us-gov:s3:::project-accumulator-glue-job
                  - arn:aws-us-gov:s3:::project-accumulator-glue-job/*

  ###############################################
  # SQL Runner Role (Shared with Dev)
  ###############################################
  SQLRunnerRole:
    Type: AWS::IAM::Role
    Properties:
      RoleName: project-cpeload-sql-runner-role
      Path: /project/
      PermissionsBoundary: arn:aws-us-gov:iam::018743596699:policy/vaec/vaec-administrator
      AssumeRolePolicyDocument:
        Version: 2012-10-17
        Statement:
          - Effect: Allow
            Principal:
              Service: ecs-tasks.amazonaws.com
            Action: sts:AssumeRole
      Policies:
        - PolicyName: project-cpeload-sql-s3-access
          PolicyDocument:
            Version: 2012-10-17
            Statement:
              - Effect: Allow
                Action:
                  - s3:GetObject
                Resource:
                  - arn:aws-us-gov:s3:::project-accumulator-glue-job/*

Outputs:
  ECSTaskExecutionRoleArn:
    Value: !GetAtt ECSTaskExecutionRole.Arn

  ECSTaskRoleArn:
    Value: !GetAtt ECSTaskRole.Arn

  SQLRunnerRoleArn:
    Value: !GetAtt SQLRunnerRole.Arn
