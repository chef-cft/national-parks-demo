### Running National Parks in GKE
You will need to have a [Google Cloud account already created](https://console.cloud.google.com/), and install the [Google Cloud SDK](https://cloud.google.com/sdk/)

NOTE: the habitat operator / updater pattern below was replace by the habitat-bastion pattern here.  Refer to the AKS demo example for a practical example, or read the docs [here](https://www.habitat.sh/docs/best-practices/#kubernetes)

### Before you begin
- `git clone https://github.com/habitat-sh/habitat-operator`
- `git clone https://github.com/habitat-sh/habitat-updater`
- create a `terraform.tfvars` 

## Prep for GKE:
You need to have a Docker Hub account set up: https://hub.docker.com/
go to: https://console.cloud.google.com/

You MUST use: the project that was created created within opscode: (Do not not create a new project!)
Enable 2 APIs: Compute Engine API, Kubernetes Engine API
1. From the Dashboard, goto APIs and Services, search for 'compute'
click on 'Compute Engine API', then click 'Enable'
2. From the Dashboard, goto APIs and Services, search for 'compute'
click on 'Kubernetes Engine API', then click 'Enable'

Create a credentials file:
From the Dashboard, goto APIs and Services, click 'credentials', then click 'create credentials', click 'Service account key', select 'JSON', fill in 'service account name' with something ex: np-gke, role should be set to owner.
This will download the json file to your local machine. 
- Update terrafrom.tfvars file: gke_credentials_file = 'location/of/json-creds.json'
- Shorten the tag_customer, tag_project, and habitat_origin: (the name cannot be longler 40 char)
- gke_project = 'your-gke-projectid' , ex: gke_project = "eric-heiser-project"

Test the configuration:
`gcloud init`
`cd terraform/gke`
`terraform init`
`terraform validate`
`terraform apply`


Publish both national-parks-demo and mongodb images to DockerHub with Builder or manually (see end of README for manual steps)

### Provision Kubernetes
1. `cd terraform/gke`
2. `terraform apply`
3. When provisioning completes you will see two commands you need to run:

   - `1_creds_command = gcloud container clusters get-credentials...`
   - `2_admin_permissions = kubectl create clusterrolebinding cluster-admin-binding...`

### Deploy Habitat Operator and Habitat Updater
First we need to deploy the Habitat Operator
1. `git clone https://github.com/habitat-sh/habitat-operator`
2. `cd habitat-operator`
3. `kubectl apply -f examples/rbac/rbac.yml`
4. `kubectl apply -f examples/rbac/habitat-operator.yml`
kubectl apply -f examples/rbac/rbac.yml && kubectl apply -f examples/rbac/habitat-operator.yml

Now we can deploy the Habitat Updater
1. `git clone https://github.com/habitat-sh/habitat-updater`
2. `cd habitat-updater`
3. `kubectl apply -f kubernetes/rbac/rbac.yml`
4. `kubectl apply -f kubernetes/rbac/updater.yml`
kubectl apply -f kubernetes/rbac/rbac.yml && kubectl apply -f kubernetes/rbac/updater.yml

### Deploy National-Parks into Kubernetes
Now that we have k8s stood up and the Habitat Operator and Updater deployed we are are ready to deploy our app.
1. `cd national-parks-demo/terraform/gke/habitat-operator`
2. Deploy the GKE load balancer: `kubectl create -f gke-service.yml`
3. Next, edit the `habitat.yml` template with the proper origin names on lines 19 and 36
4. Deploy the application: `kubectl create -f habitat.yml`
kubectl create -f gke-service.yml && kubectl create -f habitat.yml

Once deployment finishes you can run `kubectl get all` and see the running pods:
```
$ kubectl get all
NAME                                   READY   STATUS    RESTARTS   AGE
pod/habitat-operator-c7c559d7b-z5z7m   1/1     Running   0          3d1h
pod/habitat-updater-578c99fbcd-kbs2d   1/1     Running   0          3d1h
pod/national-parks-app-0               1/1     Running   0          2d14h
pod/national-parks-db-0                1/1     Running   0          3d1h

NAME                        TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)          AGE
service/kubernetes          ClusterIP      10.47.240.1     <none>          443/TCP          3d2h
service/national-parks      NodePort       10.47.241.104   <none>          8080:30001/TCP   3d1h
service/national-parks-lb   LoadBalancer   10.47.254.247   35.227.157.16   80:31247/TCP     3d1h

NAME                                     DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.extensions/habitat-operator   1         1         1            1           3d1h
deployment.extensions/habitat-updater    1         1         1            1           3d1h

NAME                                               DESIRED   CURRENT   READY   AGE
replicaset.extensions/habitat-operator-c7c559d7b   1         1         1       3d1h
replicaset.extensions/habitat-updater-578c99fbcd   1         1         1       3d1h

NAME                               DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/habitat-operator   1         1         1            1           3d1h
deployment.apps/habitat-updater    1         1         1            1           3d1h

NAME                                         DESIRED   CURRENT   READY   AGE
replicaset.apps/habitat-operator-c7c559d7b   1         1         1       3d1h
replicaset.apps/habitat-updater-578c99fbcd   1         1         1       3d1h

NAME                                  DESIRED   CURRENT   AGE
statefulset.apps/national-parks-app   1         1         3d1h
statefulset.apps/national-parks-db    1         1         3d1h
```

Find the `EXTERNAL-IP` for `service/national-parks-lb`:

`http://<EXTERNAL-IP>/national-parks`


### To update the GKE cluster:
Make sure that you have the DockerHub integration set with your <origin>/national-parks-demo
Change the pins from red to blue, or vice-versa
example: 
`cp blue-index.html src/main/webapp/index.html`

Initiate the build of the new artifact. This can be done manually or with the Github integration
Github:
`git commit -am 'changing from red to blue pins, vX.X.X'`
`git push`
Builder will watch your repo (generally national-parks-demo) and kick off a build, then publish to DockerHub.
At this point the new build is published to both Builder and DockerHub. The habitat-updater is watching for a 
new 'latest' version in Builder and will create new pod that is referenced with the 'latest' tag in DockerHub

If your DockerHub integration is not working (generally because you changed the integration after saving it the first time), you can do this manually:



### Create the DockerHub images
(used chef-cft/np-mongo, but you can also use the core plan core/mongodb)
Create a mongodb repo on Docker Hub. Fork https://github.com/chef-cft/np-mongo
do a git clone of YOUR fork ex: `git clone https://github.com/ericheiser/np-mongo.git`
`cd np-mongo` 
`hab studio enter`
`build`
`source results/last_build.env`
`hab pkg upload results/$pkg_artifact`
`hab pkg export docker results/$pkg_artifact`

Login to Docker Hub
`docker login --username=yourhubusername --password=YourPassword`
`docker login --username=yourhubusername`  <-- will prompt for password
`docker push YourOrigin/np-mongo`

### To update the gke cluster manually the steps are:
  create a new build of national-parks
  export to docker and push the image to DockerHub
  push the HART to Builder
  promote the package to the stable channel

Individual steps as follows: (as much as possible from within the studio)
`cd national-parks`
`hab studio enter`
`build`
`source results/last_build.env`
`hab pkg export docker results/$pkg_artifact`
`hab pkg install -b core/docker`
`docker login`
`docker push <docker_repo>/national-parks:latest`
`hab pkg upload results/$pkg_artifact`
`hab pkg promote $pkg_ident stable`


