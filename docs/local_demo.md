# Build/Test National-Parks App Locally:

1. Clone this repo
2. `cd national-parks-demo`
3. Export environment variables to forward ports on the `export HAB_DOCKER_OPTS='-p 8000:8000 -p 8080:8080 -p 8085:8085 -p 9631:9631'`
4. `hab studio enter`
5. `build`
6. `source results/last_build.env`
7. Load `core/mongodb` package from the public depot:  
  `hab svc load core/mongodb/3.2.10/20171016003652`
8. Override the default configuration of mongodb:
   `hab config apply mongodb.default $(date +%s) habitat/mongo.toml`
9. Load the most recent build of national-parks: 
   `hab svc load $pkg_ident --bind database:mongodb.default`
10. Load `core/haproxy` from the public depot:
  `hab svc load core/haproxy --bind backend:national-parks.default`
11. Override the default configuration of HAProxy:
  `hab config apply haproxy.default $(date +%s) habitat/haproxy.toml`
12. Run `sup-log` to see the output of the supervisor

You should now be able to hit the front end of the national-parks site as follows:

- Directly - `http://localhost:8080/national-parks`  
- HAProxy - `http://localhost:8085/national-parks`

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
3. Overwrite `src/main/webapp/index.html` with the contents of the `red-index.html` in the root directory _NOTE: the index.html has a version number hard coded on line 38. Update that to your version number if you want it to match.
4. `hab studio enter` 
5. `build`

## What's next?
We would recommend proceeding with any of the following demos to learn more about running habitat in production.

- [Habitat via containers on Azure Kubernetes Service](aks_demo.md)
- [Habitat via containers on Google Kubernetes Engine](gke_demo.md)
- [Habitat + Terraform - Running natively on VMs](terraform_demo.md)
- [Continued local testing with Habitat + Docker Compose](docker_compose_demo.md)
