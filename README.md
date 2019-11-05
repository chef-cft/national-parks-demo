# Enterprise Automation Stack - National Parks - Java Tomcat Application
This is an example Java Tomcat application packaged by [Habitat](https://habitat.sh) on VMs hardened and patched by Chef and Audited by Inspec using the "Effortless" pattern. This example app has existed for some time, and another example can be found [here](https://github.com/habitat-sh/national-parks). The differences with this example versus previous examples are the following:

- `core/mongodb` - Previous examples had you build a version of mongodb that was already populated with data before the application 
- `mongo.toml` - This repo includes a `user.toml` file for overriding the default configuration of mongodb
- `core/haproxy` = This repo uses the `core/haproxy` package as a loadbalancer in front of National Parks
- Scaling - In both the `terrform/azure` and `terraform/aws` plans there is a `count` variable which allows you to scale out the web instances to demonstrate the concept of choreography vs orchestration in Habitat.


## Usage
In order run this repo, you must first install Habitat. You can find setup docs on the [Habitat Website](https://www.habitat.sh/docs/install-habitat/).

## Demo Tracks
- Start Here: [Building national parks and running locally in the studio](examples/local_demo.md)
- [Habitat via containers on Azure Kubernetes Service](examples/aks_demo.md)
- [Habitat via containers on Google Kubernetes Engine](examples/gke_demo.md)
- [Habitat + Terraform - Running natively on VMs](examples/terraform_demo.md)
- [Continued local testing with Habitat + Docker Compose](examples/docker_compose_demo.md)


## Deploy National-Parks in Google Kubernetes Engine
Follow [these directions](gke_demo.md) to build and run national parks on Google Kubernetes Engine


## Deploy National-Parks in Azure AKS
Follow [these directions](aks_demo.md) to build and run national parks on Azure AKS


## Deploy National-Parks with Docker Compose
Follow [these directions](docker_compose_demo.md) to build and run national parks locally with docker compose
