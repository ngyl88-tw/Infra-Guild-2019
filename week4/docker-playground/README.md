## Containerisation

#### Rough Steps
- What should be the base image we should use for our spring boot app?
[X] How do we copy over my compiled jar into the docker container?
[X] What should be the first command the container should run on startup?
[X] How do we expose my app running inside the docker container and access the app on my browser?
[X] How do we view our application logs?
- How do we publish this docker image to a registry so that it is available for use by the EC2 instance?
- Given our app is containerized, what if we want to use a different version of Java? What can we do?
- Let us extend our drawing and trace the route from the Load Balancer we deployed last week to our docker container.

#### Learning Steps
1. Put the jar file into `resources/` folder, build simple docker file with COPY resources

    ```
        docker build -t my-java-app .
        docker run -it -d --name my-running-app my-java-app                 # This seems not supporting port redirection
        docker run -it -d -p 8081:8080 --name my-running-app my-java-app    # Use this to redirect to host port
        docker stop my-running-app && docker rm my-running-app
    ```
2. View logs using `docker logs -f my-running-app`

#### Learning Notes
- `CMD` vs `ENTRYPOINT`:
    [stackoverflow thread](https://stackoverflow.com/questions/21553353/what-is-the-difference-between-cmd-and-entrypoint-in-a-dockerfile)
    > - CMD or command line arguments to docker run <image> will be appended after all elements in an exec form ENTRYPOINT
      and will override all elements specified using CMD. ( ENTRYPOINT + CMD )
    > - The main purpose of a CMD is to provide defaults for an executing container. If there's >1 CMD instruction in a 
      Dockerfile, only the last CMD will take effect.
- [Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Optimize using multi-stage builds](https://docs.docker.com/develop/develop-images/multistage-build/)