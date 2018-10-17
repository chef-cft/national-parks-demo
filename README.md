# National Parks - Java Tomcat Application
This is an example Java Tomcat application packaged by [Habitat](https://habitat.sh). This example app has existed for some time, and another example can be found [here](https://github.com/habitat-sh/national-parks). The differences with this example versus previous examples are the following:

- `core/mongodb` - Previous examples had you build a version of mongodb that was already populated with data before the application 
- `mongo.toml` - This repo includes a `user.toml` file for overriding the default configuration of mongodb


## Usage
In order run this repo, you must first install Habitat. You can find setup docs on the [Habitat Website](https://www.habitat.sh/docs/install-habitat/).

### Build/Test National-Parks App: 1. Clone this repo: `git clone https://github.com/smford22/national-parks-demo.git`
2. `cd national-parks-demo`
3. `export HAB_DOCKER_OPTS='-p 8000:8000 -p 8080:8080 -p 8085:8085 -p 9631:9631 '`
4. `hab studio enter`
5. `build`
6. `source results/last_build.env`
7. `hab svc load core/mongodb`
8. `hab config apply mongodb.default $(date +%s) mongodb.toml`
9. `hab svc load $pkg_ident --bind database:mongodb.default`
10. `hab svc load core/haproxy --bind backend:national-parks.default`
11. `hab config apply haproxy.default $(date +%s) haproxy.toml`
12. `sup-log` will allow you to see the output of the supervisor

You should now be able to hit the front end of the national-parks site as follows:

- Directly - http://localhost:8080/national-parks  
- Proxy - http://localhost:8085/national-parks

You can also view the admin console for HAProxy to see how the webserver was added dynamically to the load balancer:

http://localhost:8000/haproxy-stats

```
username: admin
password: password
```

### Build a new version of the application
There is also an `index.html` file in the root of the repo that updates the map of the National-Parks app to use red pins and colored map. This can be used to demonstrate the package promotion capabilities of Habitat. 

1. create a new feature branch - `git checkout -b update_homepage`
2. Bump the `pkg_version` in `habitat/plan.sh`
3. Overwrite `src/main/webapp/index.html` with the contents of the `index.html` in the root directory _NOTE: the index.html has a version number hard coded on line 38. Update that to your version number if you want it to match.
4. `hab studio enter` 
5. `build`


## Terraform
Included in the repo is terraform code for launching the application in AWS. You will need to have an [AWS account already created](https://aws.amazon.com), and install [Terraform](https://www.terraform.io/intro/getting-started/install.html).

### Proivision in AWS
1. `cd terraform/aws`
2. `cp tfvars.example terraform.tfvars`
3. edit `terraform.tfvars` with your own values
4. `terraform apply`

This is a simple change

