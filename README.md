
# Fresh Store Docker Image

This is the docker image used by Fresh Store to run on Fresh Cloud.

## The Bitnami Source Repository
This repository is forked from https://github.com/bitnami/bitnami-docker-laravel but will be quite different as it is further developed.

The source repository is designed for development only.

Another good point of reference is this repository: https://github.com/laradock/laradock

## Build the Docker Image Locally

This will build with version 8 of Laravel
`docker build ./8/debian-10/ -t fresh-store-docker:latest`

## Start a local Container based on the docker-compose.json file 
Run this in the fresh-store repository:

`docker-compose up`

## Connect to the docker SSH 

`docker exec -it containerid bash`

`docker exec -it fresh-store bash`

## Related Projects
- Fresh Store App: https://github.com/freshlabs/fresh-store
- Fresh Cloud: https://github.com/careybaird/FreshCloud