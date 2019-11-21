## Containerisation

#### Rough Steps
- What should be the base image we should use for our spring boot app?
- How do we copy over my compiled jar into the docker container?
- What should be the first command the container should run on startup?
- How do we expose my app running inside the docker container and access the app on my browser?
- How do we view our application logs?
- How do we publish this docker image to a registry so that it is available for use by the EC2 instance?
- Given our app is containerized, what if we want to use a different version of Java? What can we do?
- Let us extend our drawing and trace the route from the Load Balancer we deployed last week to our docker container.

#### Learning Steps
1. Put the jar file into `resources/` folder, build simple docker file with COPY resources

    ```
        docker build -t my-java-app .
        docker run -it -d -p 8081:8080 --name my-running-app my-java-app
        docker stop my-running-app && docker rm my-running-app
    ```

#### Learning Notes
- `CMD` vs `ENTRYPOINT`:
    > - CMD or command line arguments to docker run <image> will be appended after all elements in an exec form ENTRYPOINT
      and will override all elements specified using CMD. ( ENTRYPOINT + CMD )
    > - The main purpose of a CMD is to provide defaults for an executing container. If there's >1 CMD instruction in a 
      Dockerfile, only the last CMD will take effect.
- 