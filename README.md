# National Parks - Java Tomcat Application
This is an example Java Tomcat application packaged by [Habitat](https://habitat.sh). This example app has existed for some time, and another example can be found [here](https://github.com/habitat-sh/national-parks). The differences with this example versus previous examples are the following:

- `core/mongodb` - Previous examples had you build a version of mongodb that was already populated with data before the application 
- `mongo.toml` - This repo includes a `user.toml` file for overriding the default configuration of mongodb


## Usage
In order run this repo, you must first install Habitat. You can find setup docs on the [Habitat Website](https://www.habitat.sh/docs/install-habitat/).


## Terraform
Included in the repo is terraform code for launching the application in AWS. You will need to have an [AWS account already created](https://aws.amazon.com), and install [Terraform](https://www.terraform.io/intro/getting-started/install.html).

Once the prereqs have been taken care...