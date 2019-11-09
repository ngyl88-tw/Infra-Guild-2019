## Terraform Playground

#### Getting Started
0. Use `asdf` to manage local dependencies. See `.tool-versions`.

    ```shell script
        asdf plugin-add terraform https://github.com/Banno/asdf-hashicorp.git
        asdf install terraform 0.12.13
    ```

0. Setup your environment variables

    ```shell script
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
