repo-root/
│
├── cloudformation/
│   └── iam-roles.yaml
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── ...
│
├── docker/
│   └── Dockerfile
│
└── .github/
    └── workflows/
        └── deploy.yml




│ Error: creating EC2 Internet Gateway: operation error EC2: CreateInternetGateway, https response error StatusCode: 403, RequestID: a3ff14c0-44f9-4c31-b074-664f8a839259, api error UnauthorizedOperation: You are not authorized to perform this operation. User: arn:aws-us-gov:sts::018743596699:assumed-role/project-accumulator-github-actions-iam-role/GitHubActions is not authorized to perform: ec2:CreateInternetGateway on resource: arn:aws-us-gov:ec2:us-gov-west-1:018743596699:internet-gateway/* because no permissions boundary allows the ec2:CreateInternetGateway action. Encoded authorization failure message: mR08NOyRPjVfde9BZ_4YPDcmtO8Ojb5O9HlyX9Vxc2kKmx6Z1rwWuiGVK8_3bVc9EsUylNxNcLdH9xm_Zw2Wb9WFAGpf2DuzOOMdZhLffaD2_FLPHeXwey3kjOL1vEbMqUi9-74qiVK7FRrz6p35VvKBJsZKWKGk1KgPOGnWXd8sb2cr45mjNKBtqSh4U_sobSnXJtZAbeudS4UeoARR_MzaCCCQqh-sau-eaAfmCra1AdI08p73VajlCGjh1TCnQI-TX3LLsO_mEzMTCXUXYZDMYdcbLR0aUE_VNCdksonx6L6WKlBNlhDWo991yhFc79mvAWF12Sakm4gFYSXYyPeXouAoTa7GVQHX9D1N2t3GbG-Z2NRB5g9x
│
│   with aws_internet_gateway.this,
│   on network.tf line 4, in resource "aws_internet_gateway" "this":
│    4: resource "aws_internet_gateway" "this" {
│
╵
╷
│ Error: creating EC2 Subnet: operation error EC2: CreateSubnet, https response error StatusCode: 403, RequestID: 15bd319f-6700-449e-8723-b4bd2dbb36a1, api error UnauthorizedOperation: You are not authorized to perform this operation. User: arn:aws-us-gov:sts::018743596699:assumed-role/project-accumulator-github-actions-iam-role/GitHubActions is not authorized to perform: ec2:CreateSubnet on resource: arn:aws-us-gov:ec2:us-gov-west-1:018743596699:vpc/vpc-0faf5f1fb582102a6 because no permissions boundary allows the ec2:CreateSubnet action. Encoded authorization failure message: xubFz7LuNY27BKmzi_qHjtGwnl59ecCv6LnIMFAeel6s4UQzehDvFGxu2bGGcSasOo4GM9DpML7Ko8m4lQ_vSet5Pl3hAnjgfDsl7cU1mjpPJhJAAZ_YQYYEYxoWVRXQwOliHtuTHq6enICMzWp8rIJNK7OATMei58XF36XNnmPUoCpj4DXnwdHwf_cfalFPBqGBjjtUe4ZrX8L8ghRt98BmaVG6vPLIblaJpotR5CBi85mQOxi-T2gDkF6lod7e5OxGwmjnzgprTedASKjZbN5UoldT0v_ORUF5AtTM2NEm3GX_h5aWM0R3W6UyQAg0YvIlzVGN8KSqnyz7ZhGIDNFJAMcISL0eaBlZe0rQMAO-2uwNNx5dXXh_7zlqESn6nXWVro6l9iXvZ0N1wOTjc7
│
│   with aws_subnet.public_a,
│   on network.tf line 15, in resource "aws_subnet" "public_a":
│   15: resource "aws_subnet" "public_a" {
│
╵
╷
│ Error: creating EC2 Subnet: operation error EC2: CreateSubnet, https response error StatusCode: 403, RequestID: f95b803e-1513-412d-a919-14c6387e4be4, api error UnauthorizedOperation: You are not authorized to perform this operation. User: arn:aws-us-gov:sts::018743596699:assumed-role/project-accumulator-github-actions-iam-role/GitHubActions is not authorized to perform: ec2:CreateSubnet on resource: arn:aws-us-gov:ec2:us-gov-west-1:018743596699:vpc/vpc-0faf5f1fb582102a6 because no permissions boundary allows the ec2:CreateSubnet action. Encoded authorization failure message: ngUogJGIgySY2V0DswLNFC33Hux9EjEi6fo8txtWfxURsbv92SedpyTWeVgiDzqg9jRSQi5j5uq3YitAuNggxDmquIRb4pIDkMxaKlcdyESm_Tbgs1Ee4a8zUBlh-eM3tbzTMowUceN9uEasHvK1wZ7mNdK7SSGNwiIsI7E19dHj4ZmtWj3I1fNCXnYdVEihrq87A0TDVh98q862XzFqL_vcIN2pnLG4vgSUZqJKp39Df-IuHphLXPJQd7A1PJ28aTAtCphlFubGxRPZhJMkSLvwcqdj27YyQt_2yaqLLsHFVJiAOJFKfmNY9uyGoiAAq6sZXBTbKEgECzLKYCRSy7dQJK1E6nl-gVRJf-asZiLABJWuEtVaW2dp5KI51p6T5BgNQOD03KGDotg9UTVC48
│
│   with aws_subnet.public_b,
│   on network.tf line 26, in resource "aws_subnet" "public_b":
│   26: resource "aws_subnet" "public_b" {
│
╵
╷
│ Error: creating EC2 EIP: operation error EC2: AllocateAddress, https response error StatusCode: 403, RequestID: 709ef44a-8ad3-42fa-8d8a-45b85bbf15f4, api error UnauthorizedOperation: You are not authorized to perform this operation. User: arn:aws-us-gov:sts::018743596699:assumed-role/project-accumulator-github-actions-iam-role/GitHubActions is not authorized to perform: ec2:AllocateAddress on resource: arn:aws-us-gov:ec2:us-gov-west-1:018743596699:elastic-ip/* because no permissions boundary allows the ec2:AllocateAddress action. Encoded authorization failure message: 8emSiCwfomSvu7IKCuxvZCTQrBApzZSD-kmemoP8ANQ5wOKo_JmX8auUaVAGEhtFrnPl51cC6uVIvZ972hHmZEmtWVIislHgRI4FoGJ93J8_A0w4X_i99v0pL44SY2PX1eGE1vQUGFcw2j4yk5XC132f3wPqSH40nR2OT2LPHjzTGp_mE_w0HMHACKozlmaWgr1xUTMmUFGJrzTm4db-YYPagRtiBPUubGBY0LXBdhAK6Pya4ZGyU1OACf6tzBj-Rm2x8Uttqwszf4Q4sEUU8fUReRpmyOpg39ewqyffEif89ZCQ-vULY_YBvIkB-2wiCE4q0DoZ9nO9daJ3oCpLW0CbGMwcjb-rFQZw5HWcc6oqQyrzpqAK7z8I2b0MUjto0hkHmCQfCvyGKdY79cXHpKoQXnX31
│
│   with aws_eip.nat,
│   on network.tf line 66, in resource "aws_eip" "nat":
│   66: resource "aws_eip" "nat" {
│
╵
╷
│ Error: creating EC2 Subnet: operation error EC2: CreateSubnet, https response error StatusCode: 403, RequestID: 3b15d441-b97d-42c8-a551-8622a0acd865, api error UnauthorizedOperation: You are not authorized to perform this operation. User: arn:aws-us-gov:sts::018743596699:assumed-role/project-accumulator-github-actions-iam-role/GitHubActions is not authorized to perform: ec2:CreateSubnet on resource: arn:aws-us-gov:ec2:us-gov-west-1:018743596699:vpc/vpc-0faf5f1fb582102a6 because no permissions boundary allows the ec2:CreateSubnet action. Encoded authorization failure message: w9MdLxws9Hc8Yux9yBElMGdr_1pIlLQyA8uiQGFKl7sEOvCP26189LDXzVJl2sntjSi_fa-e7eToMW3aEcm-qMMq9ce1cYpO6T42FwX06RNaHYmOgtygyopAPZUKz_rSp07n5eeVkystqKZa7rvc1MSYCNYaWdXDKzJiZ5YrHQdhwn9m7sENakR_kKmosUmzsHRvWJGW_0SyasLfxm54IgtPmb75O-4EGaY5xdw6AlJ-pyOdKBfPLZyKJEYK6pGMvZ3jpBIDdxTmX4CPxa47cPJ9g11sXXMRpVowB1qfhq_tKs9WK7d0nEh-UOd-4DI1f1p_a_GLnFM10MtvlvYMRIB031O7hGq90dYSNT3MAKatlpcBaoLqSh-YT4Mh30kx8CLpu712vORLxaoic5GQII
│
│   with aws_subnet.private_a,
│   on network.tf line 86, in resource "aws_subnet" "private_a":
│   86: resource "aws_subnet" "private_a" {
│
╵
╷
│ Error: creating EC2 Subnet: operation error EC2: CreateSubnet, https response error StatusCode: 403, RequestID: a5b2ff4c-cf41-435a-9c43-e818fa62ceb8, api error UnauthorizedOperation: You are not authorized to perform this operation. User: arn:aws-us-gov:sts::018743596699:assumed-role/project-accumulator-github-actions-iam-role/GitHubActions is not authorized to perform: ec2:CreateSubnet on resource: arn:aws-us-gov:ec2:us-gov-west-1:018743596699:vpc/vpc-0faf5f1fb582102a6 because no permissions boundary allows the ec2:CreateSubnet action. Encoded authorization failure message: mtUUfHVd0ceiDcyE8eNucagzgHOaLGUnjEGGCwhb24U1ISgh3nzC1YeM41MW4pilpvCGQMlsOjmACwRy5vOqO1qkUlyob2bjNgCSL9r-KCZUVZciohOkn_IceL5O-oRYrBPzII3bNZrLRm8pdiyjxY46mgMAE3g06CiaDmK3OSwVyzSqwQEdaJ9szljx8IpLPSdUj2KK4o57lPIvnwDnOJzKdTsg71EpUDiclmYdwWSuUEgSp_BStNX-4vGn_wzuB781gdkvQERDZ4NoRBE1BYmV9zEUuLplTDrnxYP2-v6fbeDECypTIBrurZ_1M6jfoN8uDq-SDY2gc9kX-jgagWhXmi7FumppSJPd6SAkL2RjaCGnyw1edtpm0gPoFlFshG-ouFPCPz7ZeyOa8IlBRv
│
│   with aws_subnet.private_b,
│   on network.tf line 96, in resource "aws_subnet" "private_b":
│   96: resource "aws_subnet" "private_b" {
│
╵
Error: Terraform exited with code 1.
Error: Process completed with exit code 1.
 
 

