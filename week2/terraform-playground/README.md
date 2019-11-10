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
#### To-Dos

- [X] create an EC2 in default vpc, ability to ssh
- [X] provision EC2 with java and files, verify with ssh and `curl localhost:8080`
- [X] expose ports, route traffic to the ec2
- [ ] try alternatives for provisioners?
- [ ] move out from default vpc
- [ ] 2-tier architecture?

---
#### Important Notes
- Existing instances have to be destroyed and recreate whenever addition/modification of provisioner(s) takes place.
    - eg. changes in `bootstrap.sh`
- Use `ps aux | grep hello` to get the user who runs the process

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
    - HashiCorp Packer
        - custom image could be used with `user data` so that to pass the necessary information into each instance
        - instances can register itself with the configuration management server immediately on boot
        - can avoid the need to accept commands from Terraform
