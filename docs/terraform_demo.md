# Running National Parks on VMs with Terraform
Included in the repo is Terraform code (Version `0.12`) for launching the application in AWS and Google Kubernetes Engine. Provision either AWS, GKE, or both, and then you can watch Habitat update across cloud deployments.

Due to how often Terraform is updated, it's recommended to use `tfswitch`. This will help alleviate any problems with version incompatabilities.

Terraform installation guide is [here](https://www.terraform.io/intro/getting-started/install.html).
The `tfswitch` tool is available [here](https://github.com/warrensbox/terraform-switcher)

The demo now sets a specific Chef Automate password and Chef Automate token for simplicity. Please change the default token value in your `terraform.tfvars` 

## Deploy Chef Automate
1. `cd terraform/chef-automate/(aws|azure|gcp)`
2. `cp tfvar.example terraform.tfvars`
3. `$EDITOR terraform.tfvars`
4. `terraform apply`

#### Note: The Chef Automate with EAS demo is currently only working in AWS (see [this issue](https://github.com/chef-cft/national-parks-demo/issues/29) if you want to add to azure). The demo disables tls for just the application service. This is the default setting for production deploys please see Chef Automate docs for enabling encryption.

```
disable_event_tls = "true"
```
Once you automate instance is up it will outpfut credentials to login and an automate token:

```
Outputs:

a2_admin = admin
a2_admin_password = <password>
a2_token = <token>
a2_url = https://scottford-automate.chef-demo.com
chef_automate_public_ip = 34.222.124.23
chef_automate_server_public_r53_dns = scottford-automate.chef-demo.com
```

## Proivision National-Parks in AWS
You will need to have an [AWS account already created](https://aws.amazon.com)

1. `cd terraform/aws`
2. `cp tfvars.example terraform.tfvars`
3. edit `terraform.tfvars` with your own values and add in the `automate_url` and `automate_token` from the previous step
4. `terraform apply`

Once the provisioning finishes you will see the output with the various public IP addresses
```
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

haproxy_public_ip = 34.216.185.16
mongodb_public_ip = 54.185.74.152
national_parks_public_ip = 34.220.209.230
permanent_peer_public_ip = 34.221.251.189
```

`http://<haproxy_public_ip>:8085/national-parks`
or
`http://<haproxy_public_ip>:8000/haproxy-stats`

## Proivision National-Parks in Azure
You will need to have an [Azure account already created](https://azure.microsoft.com/en-us/features/azure-portal/)

1. `cd terraform/azure`
2. `terraform init`
3. `az login`
4. `cp tfvars.example terraform.tfvars`
5. edit `terraform.tfvars` with your own values and add in the `automate_url`, `automate_ip`  and `automate_token` from the previous step
6. `terraform apply`

Once provisioning finishes you will see the output with the various public IP addresses:
```
Apply complete! Resources: 19 added, 0 changed, 0 destroyed.

Outputs:

haproxy-public-ip = 40.76.29.195
instance_ips = [
    40.76.29.123
]
mongodb-public-ip = 40.76.17.2
permanent-peer-public-ip = 40.76.31.133
```

Like in the AWS example, you will be able to access either `http://<haproxy_public_ip>:8085/national-parks`
or
`http://<haproxy_public_ip>:8000/haproxy-stats`

## Scaling out Azure and AWS Deployments
Both the AWS and Azure deployments support scaling of the web front end instances to demonstrate the concept of 'choreography' vs 'orchestration' with Habitat. The choreography comes from the idea that when the front end instances scale out, the supervisor for the HAProxy instance automatically takes care of the adding the new members to the pool and begins balancing traffic correctly across all instances.

### Scaling out
1. In your `terraform.tfvars` add a line for `count = 3`
2. run `terraform apply`
3. Once provisioning finishes, go to the `http://<haproxy-public-ip>:8000/haproxy-stats` to see the new instances in the pool
