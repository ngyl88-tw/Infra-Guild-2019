## Terraform Playground

#### Getting Started
0. Setup your environment variables

    ```
        export AWS_ACCESS_KEY_ID=<AWS_ACCESS_KEY_ID>
        export AWS_SECRET_ACCESS_KEY=<AWS_SECRET_ACCESS_KEY>
        export AWS_DEFAULT_REGION=<AWS_DEFAULT_REGION>
    ```
0. Setup `sensitive.tfvars`.
---
#### Terraform Commands
- `terraform init`

- `terraform plan`
    - `terraform plan -var-file=../config/default.tfvars -var-file=../config/sensitive.tfvars  -out=./.terraform/plan.tf`

- `terraform apply`
    - `terraform apply "./.terraform/plan.tf"`

- `terraform output`

- `terraform refresh`: update state file (sync with real-world infra), will also generate outputs
