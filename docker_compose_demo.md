### Docker Compose Directions

To quickly spin up the demo locally after mongodb and national-parks images are pushed to DockerHub.
change `docker-compose.yml` to use your DockerHub repo line 8.
ex: `     image: ericheiser/national-parks:latest`

Then run: `docker-compose up`
To clean up, run: `docker-compose down`
