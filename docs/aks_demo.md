# Running national parks demo on Azure AKS
NOTE: This demo requires that you're running the Azure CLI version 2.0.75 or later. Run `az --version` to find the version. [Click here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) if you need to install or upgrade.

Portions of this demo are sourced from https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-deploy-application

This demo produces linux habitat artifacts and linux containers.  Running the build steps below requires a linux or macos environment.

## Prerequisites
- A linux or macos workstation (does not work on Windows)
- `azure-cli` >= 2.0.75
- `docker` >= 19.0.0
- `chef habitat` >= 0.83.0

### Step 1: Build national parks / export to docker / test locally
#### national-parks
Clone this repo, and navigate to the root.  Then make a build and export it to docker
```
git clone <this url>
cd national-parks
hab studio enter
build
source results/last_build.env
hab pkg export docker results/$pkg_artifact
```
#### mongodb
We can pull mongodb from the chef-maintained habitat depot
```
hab pkg install core/mongodb/3.2.10
hab pkg export docker core/mongodb/3.2.10
```

### hab bastion
This is a noop hab service we can export to docker and use as a permanent peer in kubernetes [see here for details](https://www.habitat.sh/docs/best-practices/#kubernetes)
```
cd examples/kubernetes-hab-bastion
hab studio enter
build
source results/last_build.env
hab pkg export docker results/$pkg_artifact
```

#### Local testing with docker-compose
Use the directions [here](docker_compose_demo.md) to test this with docker compose.

### Step 2: Create an Azure Container Registry

#### Login to azure
```
az login
```

#### Create a new resource group
```
az group create --name exampledemo --location westus
```
NOTE: replace `exampledemo` with a name of your choice.

#### Create the container registry
```
az acr create --resource-group exampledemo --name exampleacr --sku Basic
```
NOTE 1: Replace `exampledemo` with your resource group name, and `exampleacr` with a name of your choice.

NOTE 2: ALSO, the ACR name must be alphanumeric (no dashes or hyphens). sku is compute size, listed [here](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-skus)

NOTE 3: This ACR name must be unique to you and your project as it lives in a global public namespace.

#### Login to the acr
```
az acr login --name exampleacr
```


#### Get the login server
```
az acr list --resource-group exampledemo --output table
```
#### Upload docker images to ACS
```
docker tag jvdemo/national-parks:7.0.0 exampleacr.azurecr.io/national-parks:7.0.0
docker push exampleacr.azurecr.io/national-parks:7.0.0

docker tag core/mongodb:3.2.10 exampleacr.azurecr.io/mongodb:3.2.10
docker push exampleacr.azurecr.io/mongodb:3.2.10

docker tag jvdemo/hab_bastion:latest exampleacr.azurecr.io/hab_bastion:latest
docker push exampleacr.azurecr.io/hab_bastion:latest
```
You now have a container image that is stored in a private Azure Container Registry instance. You can view it with the following:

```
az acr repository list --name exampleacr --output table
```

### Step 3: Create Azure Kubernetes Service
```
az aks install-cli
az aks create \
    --resource-group exampledemo \
    --name exampleaks \
    --node-count 2 \
    --generate-ssh-keys \
    --attach-acr exampleacr
```
NOTE 1: Remember to replace `example` with a name of your choice.

NOTE 2: If you get a authorization error, you may have to login to azure again by running `az login`.

#### Get AKS Credentials
```
az aks get-credentials --resource-group exampledemo --name exampleaks
```
(stores creds in `$HOME/.kube/config`)

### Step 4: Load your containers into k8s using a manifest file

#### Replace your images namespaces in the manifest file, and push to AKS
Replace my namespaces with what you created.

(Replace any line that looks like: `image: exampleacr.azurecr.io/mongodb:3.2.10` with _your_ ACR ie: `youracr.azurecr.io/mongodb:3.2.10`)
```
vi examples/k8s-manifest-with-bastion.yml
kubectl apply -f examples/k8s-manifest-with-bastion.yml
```
Get the IP (may have to run multiple times)
```
kubectl get service
```
Open in browser

### Running an Update
1. Update an index page (`cp red-index.html src/main/webapp/index.html`)
2. Bump package version to 7.1.0 (`vi habitat/plan.sh`)
3. Produce a new build:
```
hab studio enter
build
hab pkg export kubernetes jvdemo/national-parks
```
4. Tag and upload it (outside of studio)
```
docker tag jvdemo/national-parks:7.1.0 exampleacr.azurecr.io/national-parks:7.1.0
docker push exampleacr.azurecr.io/national-parks:7.1.0
```
5. Update kubernetes cluster with new version
```
kubectl set image deployment national-parks-app national-parks-app=exampleacr.azurecr.io/national-parks:7.1.0
```

### Post-Demo Clean Up
1. Go into the national parks directory and run:  `kubectl delete -f examples/k8s-manifest-with-bastion.yml`
2. Go into azure and delete the resource group you created (`exampledemo`)
