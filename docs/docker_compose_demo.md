# Running National Parks in Docker Compose

This requires that you have exported national-parks and mongodb to your local container registry. See the bottom of this document for instructions.

Important: You need to change `examples/docker-compose.yml` to use your origin on line 15.  You can leave mongodb set to `core`.

(Example: `example/national-parks` >> `yourorigin/national-parks`)

Then follow these steps to launch (outside of hab studio):
```
cd examples
docker-compose up
```

Open a browser and navigate to [http://localhost:8080/national-parks](http://localhost:8080/national-parks).  Use `ctrl-c` to quit.

To clean up, run: `docker-compose down`

## Example steps to build required docker images

(from the root of this repo)
### National Parks
```
hab studio enter
build
source results/last_build.env
hab pkg export docker results/$pkg_artifact
```
### MongoDB
```
hab studio enter
hab pkg install core/mongodb/3.2.10
hab pkg export docker core/mongodb/3.2.10
```