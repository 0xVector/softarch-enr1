1. Pull the docker image:
```
docker pull structurizr/lite
```

2. Go to the github repo directory and run:
```
docker run -it --rm -p 8080:8080 -v ${GITHUB-REPO-DIRECTORY-PATH}:/usr/local/structurizr structurizr/lite
```
Replace `${GITHUB-REPO-DIRECTORY-PATH}` with an absolute path of our GitHub repo.
This starts the Structurizr server on `localhost:8080`. I set it up to hot reload every 5000ms, this can be changed in `structurizr.properties`.

3. Enjoy
