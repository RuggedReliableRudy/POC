name: Deploy PGActive Cluster

on:
  push:
    branches: [ "Accumulator-dev" ]

permissions:
  id-token: write
  contents: read

jobs:
  terraform:
    # If you want to run on your self-hosted runner:
    # runs-on: [self-hosted, docmp-accumulator]
    runs-on: ubuntu-latest

    steps:
      # -------------------------------------------------------
      # Checkout repository
      # -------------------------------------------------------
      - name: Checkout repository
        uses: actions/checkout@v4

      # -------------------------------------------------------
      # Configure AWS Credentials (OIDC → GovCloud)
      # -------------------------------------------------------
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_GOVCLOUD_ROLE_ARN }}
          aws-region: us-gov-west-1
          audience: sts.amazonaws.com
          output-env-credentials: true

      # -------------------------------------------------------
      # Install Terraform
      # -------------------------------------------------------
      - name: Set up Terraform
        uses: hashicorp/setup-terraform@v3

      # -------------------------------------------------------
      # Terraform Init
      # -------------------------------------------------------
      - name: Terraform Init
        run: terraform init

      # -------------------------------------------------------
      # Terraform Validate
      # -------------------------------------------------------
      - name: Terraform Validate
        run: terraform validate

      # -------------------------------------------------------
      # Terraform Plan
      # -------------------------------------------------------
      - name: Terraform Plan
        run: terraform plan -out=tfplan

      # -------------------------------------------------------
      # Terraform Apply
      # -------------------------------------------------------
      - name: Terraform Apply
        run: terraform apply -auto-approve tfplan

      # -------------------------------------------------------
      # Output DB Endpoints (for logs)
      # -------------------------------------------------------
      - name: Show Terraform Outputs
        run: terraform output
