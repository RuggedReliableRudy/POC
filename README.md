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



╷
│ Error: modifying RDS DB Parameter Group (pgactive-params): operation error RDS: ModifyDBParameterGroup, https response error StatusCode: 400, RequestID: 390daf4a-eb8c-49e3-b9b2-7b10672b9a14, api error InvalidParameterValue: Could not find parameter with name: wal_level
│
│   with aws_db_parameter_group.pgactive,
│   on main.tf line 72, in resource "aws_db_parameter_group" "pgactive":
│   72: resource "aws_db_parameter_group" "pgactive" {
│
╵
╷
│ Error: creating EC2 Internet Gateway: operation error EC2: CreateInternetGateway, https response error StatusCode: 403, RequestID: 539fb160-8aac-42b7-a50b-6b44db6fd6d0, api error UnauthorizedOperation: You are not authorized to perform this operation. User: arn:aws-us-gov:sts::018743596699:assumed-role/project-accumulator-github-actions-iam-role/GitHubActions is not authorized to perform: ec2:CreateInternetGateway on resource: arn:aws-us-gov:ec2:us-gov-west-1:018743596699:internet-gateway/* because no permissions boundary allows the ec2:CreateInternetGateway action. Encoded authorization failure message: uzhQeqw3RXzAVbBps8w4HrvJ05suyvHltqZ1YMuN3TJ8lUG7fRqoeqAc0pi6kb2QRNJyrSukulVqQctmgzTNxHYSEJr-lR5__y4OwxUm9hKkeULTYzV0Mr7mab5sd83KIRb0CbCwXzCOBJ2IBEWZdqgCQVY4P5-z9lVpb9etnm7ZQj9JSx35MqwURqQ0ZG_0HmwmQdf5-5wkc4YV0TrHEz2tCCSFu_-mgNZBoYFqudu_WYmzam1tBD09oFMxoGJLcGMIkiYdUjXHbHMKteVUZoKqUebmLv-Vnk0qmX-WmFkJ9vGDgjKjSprmfpcY6GtAAH0XFzRZ558sZFwawMHQR0qZkd_1NmuM5JsYI3xQGfapY09hACFDnf1B
│
│   with aws_internet_gateway.this,
│   on network.tf line 4, in resource "aws_internet_gateway" "this":
│    4: resource "aws_internet_gateway" "this" {
│
╵
╷
│ Error: creating EC2 Subnet: operation error EC2: CreateSubnet, https response error StatusCode: 403, RequestID: 38378918-2c20-459b-b919-fda333cf8987, api error UnauthorizedOperation: You are not authorized to perform this operation. User: arn:aws-us-gov:sts::018743596699:assumed-role/project-accumulator-github-actions-iam-role/GitHubActions is not authorized to perform: ec2:CreateSubnet on resource: arn:aws-us-gov:ec2:us-gov-west-1:018743596699:vpc/vpc-0faf5f1fb582102a6 because no permissions boundary allows the ec2:CreateSubnet action. Encoded authorization failure message: jpPst6GNTnP1q0DN1ysA6aHpkptrEwxlKgbJjXNwhElhb5tJ-mIbYRuk_NoIPZ6A4oxdmqe_vNeIWzRICcTB-jGMEHrzNtIAUhcTawHVSTXQ5aFcy2mhZlfdTwbf5NPynhjzzytqT92oLEoUwHiPofem9c58U3-ajkv9Ov6T3aEltBzoCrUBp6Zp9m6upmUVgJGZdSNhAqGzP6Knw8AWQr0Hof8Xz8HyTzztrYyXTjKxIuTkD5f8SaZujQDKo3eMhDilt-nm9TVoqDcml_LzqBO4X1qvCyyuVf1FHbn0jKBynsfKQUWcAD0GoX7UcnP3xxSrRefft7b97-WONYPUMDZeEvIoDxOl9jW3F_u2Emgh0nVJkfMWaiECBWtqChT347Qf2R4m5jeXsckTRIdzWF
│
│   with aws_subnet.public_a,
│   on network.tf line 15, in resource "aws_subnet" "public_a":
│   15: resource "aws_subnet" "public_a" {
│
╵
╷
│ Error: creating EC2 Subnet: operation error EC2: CreateSubnet, https response error StatusCode: 403, RequestID: e9888b88-0a67-4534-9a86-3c9053f0a3d5, api error UnauthorizedOperation: You are not authorized to perform this operation. User: arn:aws-us-gov:sts::018743596699:assumed-role/project-accumulator-github-actions-iam-role/GitHubActions is not authorized to perform: ec2:CreateSubnet on resource: arn:aws-us-gov:ec2:us-gov-west-1:018743596699:vpc/vpc-0faf5f1fb582102a6 because no permissions boundary allows the ec2:CreateSubnet action. Encoded authorization failure message: IGAW9rw6ZA_-4vsYFubEM8OS62tgTIk3VSOCyW96eA6p5GJ-bYKrYqdWf9UgaGc0zI20-3XpdCF6f4gBZXN8-jwLj5hBzUryMDAWPiTiHsiUwQY1D9QF7xtZKuHynhuW_njVl2wrLpBbmk8E4n8_WglD8X5avR2pAlffka2YjEfClaJ3IsRJjnh2Pkgi9SCPNXSoPlkeqJ1b6WkZk-T7uVCJURqE3fMq-8Kh5ofhzFr6MLK1a54XOquQ4VmTCMCM3S69u5wbxTMLSZ3Mw2zz9p56sO6Js7xw_DEXhKNUWbx8gt43SSxuWTmLQiYwnz3XMqQNVMOF2O6GRCyr1hJKw2MQ3KNj9nFyEhOUIi1V-5xIiG6JNO_ieHqna_UhF2E4JH6eBCcDYipv7XML-g2AL2
│
│   with aws_subnet.public_b,
│   on network.tf line 26, in resource "aws_subnet" "public_b":
│   26: resource "aws_subnet" "public_b" {
│
╵
╷
│ Error: creating EC2 EIP: operation error EC2: AllocateAddress, https response error StatusCode: 403, RequestID: 87e8967d-e79e-47d7-b3d3-f94b983ac8f8, api error UnauthorizedOperation: You are not authorized to perform this operation. User: arn:aws-us-gov:sts::018743596699:assumed-role/project-accumulator-github-actions-iam-role/GitHubActions is not authorized to perform: ec2:AllocateAddress on resource: arn:aws-us-gov:ec2:us-gov-west-1:018743596699:elastic-ip/* because no permissions boundary allows the ec2:AllocateAddress action. Encoded authorization failure message: gtSSA_Tk76M5GyiNuMRRlxiJ7EdiRPajUQkVFFjg4xy0NNgF4lferTlzq00hmNEPzOaL1GPjVc6k-CvmS6VvsTElGryJLmEJfgFWgR9RgynqqiuoalxOpX6wWBhhksZB22aqmPiRX_F2zdCWfIhVV3e1aHSElClcztkQjBnTOAxNOdTl-R8KMrx9075YV2ix0GAyKMHtaSLzJh-v6oSfUWWjXIY2YYd7YN8za79_lSuXRMTUjsh5T5vFPFKxEkNDW2JSY7pNb-UDj4YVkgxQSJwkSYJ7svfZDqN8fz1u0MIsYZtDayetls-4C49gn_ybBM0hMnXKhvouyAOGhv3pwktlPoWgQoFBiEPhzSXjwD6Wxhl_eL_zYfHEE1VScHn2xZMdhJOs-K5tkT9JE8JQ2t2oMtcbc
│
│   with aws_eip.nat,
│   on network.tf line 66, in resource "aws_eip" "nat":
│   66: resource "aws_eip" "nat" {
│
╵
╷
│ Error: creating EC2 Subnet: operation error EC2: CreateSubnet, https response error StatusCode: 403, RequestID: e62b2668-4d4e-4aea-9a33-7da49e5ca288, api error UnauthorizedOperation: You are not authorized to perform this operation. User: arn:aws-us-gov:sts::018743596699:assumed-role/project-accumulator-github-actions-iam-role/GitHubActions is not authorized to perform: ec2:CreateSubnet on resource: arn:aws-us-gov:ec2:us-gov-west-1:018743596699:vpc/vpc-0faf5f1fb582102a6 because no permissions boundary allows the ec2:CreateSubnet action. Encoded authorization failure message: gvlyRWgEOxfHJdxn64raA1PPhfQ7MB-yNBOvJA0l17HBD75K8Pn9RsTHpqRL7ko9t5ueW5rPjo70vYBH74wxX8fYEYFIX6cL9D-2eJJQY6BuMHlqc7ne0IVtGn4LHXNZPtf36e-L6P62cQpGAXorLiXALG5wope59mm-DXyF-tuLVb_g4CsJn5AoW739Yn-9jZix-A0nRtEWWTHGbF29ZBRro0USIBMevaDeHV7FHiv2fbgDAzfJ3rjTk1co23gNiOe5SHekMgt7I9EAJyjQrsK6Ilk38-3xWkmb_igZ_Z6b-3BbOtfIhGwMBRopbUVd0v3CXSuJlTPefmeOt9F1pnoeDT43sYjqL5iHJu9HBO8u9H4VneaqeF1tCwf7I_-dScgUrBS4u1e4xJfI5Th6iV
│
│   with aws_subnet.private_a,
│   on network.tf line 86, in resource "aws_subnet" "private_a":
│   86: resource "aws_subnet" "private_a" {
│
╵
╷
│ Error: creating EC2 Subnet: operation error EC2: CreateSubnet, https response error StatusCode: 403, RequestID: c0dbfe66-8d5c-49d7-a8ee-aac7675bf24c, api error UnauthorizedOperation: You are not authorized to perform this operation. User: arn:aws-us-gov:sts::018743596699:assumed-role/project-accumulator-github-actions-iam-role/GitHubActions is not authorized to perform: ec2:CreateSubnet on resource: arn:aws-us-gov:ec2:us-gov-west-1:018743596699:vpc/vpc-0faf5f1fb582102a6 because no permissions boundary allows the ec2:CreateSubnet action. Encoded authorization failure message: O_aueR5AllHhlC89ahhHNIwGXY8jkOXLxq98SpVtlkOIRq25vBJe3aBlu_uWUJUuD3yMPgNPqp_w6XS-_j-qbkOs0EJ1WpWtcD6HqAAsQLuOLyJ7v6E4zddHfd95Y7Yo5nDh_WWrUM-SIulW0F1aWi-m_4Z8RiPVjIMoWJk3fRf7C5t2lesrNUmYBuuuXrDtlkTfh3m-2aE2yvcOr3vselPoVl2-K9HsHMlCcF3FHuz4qPpuphqGahM-Ndf9TFNN_9v9vm7yNeGfi3MiH7ff1EsAdeHC4_znLMkUh6J1udkmmDErIG04hskHEzekKpBorRUtDCQh_XLJrSn2Ks6DGDlILEsOVFrfpr4y5s2rToc-G7tPl_m9hcOUVwI-Fh1P-o5MaDXDzbZnu0LUVggtZQ
│
│   with aws_subnet.private_b,
│   on network.tf line 96, in resource "aws_subnet" "private_b":
│   96: resource "aws_subnet" "private_b" {
│
╵
Error: Terraform exited with code 1.
Error: Process completed with exit code 1.
