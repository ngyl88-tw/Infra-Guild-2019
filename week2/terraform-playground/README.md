## Terraform Playground

#### Getting Started
0. Use `asdf` to manage local dependencies. See `.tool-versions`.

    ```shell script
        asdf plugin-add terraform https://github.com/Banno/asdf-hashicorp.git
        asdf install terraform 0.12.13
    ```

0. Setup your environment variables, or use `aws_profile` in `default.tfvars`.

    ```shell script
        export AWS_ACCESS_KEY_ID=<AWS_ACCESS_KEY_ID>
        export AWS_SECRET_ACCESS_KEY=<AWS_SECRET_ACCESS_KEY>
        export AWS_DEFAULT_REGION=<AWS_DEFAULT_REGION>
    ```
0. Setup `sensitive.tfvars`.
---
#### To-Dos

- [X] create an EC2 in default vpc, ability to ssh
- [X] provision EC2 with java and files, verify with ssh and `curl localhost:8080`
- [X] expose ports, route traffic to the ec2
- [X] use terraform `data-source` to retrieve AMI
- [ ] try alternatives for provisioners?
- [ ] move out from default vpc
    - Need to create public subnet, internet
    - Update `aws_instance` in `main.tf` to deploy in correct subnet?
- [ ] 2-tier architecture?

---
#### Learning Notes
- Built-in provisioner (to be used with cautions)
    - Existing instances have to be destroyed and recreate whenever addition/modification of provisioner(s) takes place, eg. changes in `bootstrap.sh` 
    - Terraform might not be aware when `remote-exec` fails
        - Explicit command `set -e` is required in `remote-exec` for the `aws_instance` to be marked as tainted.
        - `set -o pipefail` in `bootstrap.sh` doesn't make any difference as long as `set -e` is defined inline in `remote-exec`.
        - `remote-exec` seems not supporting `set -o pipefail`
        - Otherwise, have to be fixed by `manual taint` or `terraform destroy`.
    - When `remote-exec` fails, `terraform output` is not yet updated. Use console to get the public ip.
    - Also not recommended for the following reasons:
        - separation of provisioning (vm, machine) vs configuration management (software downloads, app)

- Use `ps aux | grep hello` to get the user who runs the process

- EC2 commands to help filtering AMI
    - index `-1` returns the most recent image

    ```shell script
        aws ec2 describe-images --query 'sort_by(Images, &CreationDate)[].Name' \
            --owners '099720109477' \
            --filters "Name=architecture,Values=x86_64" "Name=name,Values=ubuntu/*/ubuntu-bionic-18.04-*" \
                "Name=root-device-type,Values=ebs" "Name=virtualization-type,Values=hvm"
  
        aws ec2 describe-images --query 'sort_by(Images, &CreationDate)[-1].{ID:ImageId, Name:Name}' \
            --owners '099720109477' \
            --filters "Name=architecture,Values=x86_64" "Name=name,Values=ubuntu/*/ubuntu-bionic-18.04-*" \
                "Name=root-device-type,Values=ebs" "Name=virtualization-type,Values=hvm"
    ```

---
#### Terraform Commands
- `terraform init`

- `terraform plan`
    - `terraform plan -var-file=../config/default.tfvars -var-file=../config/sensitive.tfvars -out=terraform.tfplan`
    - `terraform plan -destroy -var-file=../config/default.tfvars -var-file=../config/sensitive.tfvars -out=terraform.tfplan`

- `terraform apply`
    - `terraform apply "terraform.tfplan"`

- `terraform output`

- `terraform refresh`: update state file (sync with real-world infra), will also generate outputs

- `terraform destoy`
---
#### EC2 Provisioning
[Provisioners (remote-exec)](https://www.terraform.io/docs/provisioners/remote-exec.html#script-arguments)
- Provisioners should only be used as a last resort? Why?
    - can be used to execute scripts on a local or remote machine as part of resource creation or destruction.
- Mentioned in [main Provisioner page](https://www.terraform.io/docs/provisioners/)
    - prefer to use that provider functionality rather than a provisioner so that Terraform can be fully aware of the object and properly manage ongoing changes to it.
    - All `provisioner` support the `when` (`destroy`, run during instance creation by default) and `on_failure` (`continue` or `fail`) meta-arguments.
    - Creation-time provisioners are only run during creation, not during updating or any other lifecycle.
    - Destroy-time provisioners to be used with care
        - If a resource block with a destroy-time provisioner is removed entirely from the configuration, its provisioner configurations are removed along with it and thus the destroy provisioner won't run.
        - A destroy-time provisioner within a resource that is tainted will not run.
- alternatives:
    - cloud-init
        - automatically run arbitrary scripts and do basic system configuration immediately during the boot process
        - without the need to access the machine over SSH
        - can make use of the `user data` or `metadata` if building custom machine images
        - allow faster boot by avoiding the need for direct network access from Terraform to the new server
        - some useful log location: logs under `/var/log/cloud-init.log` and `/var/log(s)/user-data.log` if can ssh into the machine.
    - HashiCorp Packer
        - custom image could be used with `user data` so that to pass the necessary information into each instance
        - instances can register itself with the configuration management server immediately on boot
        - can avoid the need to accept commands from Terraform
---
#### Using saml2aws
Ref: https://github.com/emmasun-tw/infra101/blob/master/week2/saml2aws.md

After login, update variable `aws_profile` in `default.tfvars`.

```shell script
    saml2aws configure
    saml2aws login
```

saml2aws configure with profile `okta-beach`.

---
