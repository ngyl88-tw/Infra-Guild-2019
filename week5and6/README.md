# Kubernetes
---
## Week 5

#### Steps

1. Start a Kubernetes cluster on your local machine using Docker
   - Enable it here: `Preferences` > `Kubernetes` 
   - You may want to temporarily increase the Memory and CPU allocated for Docker for better performance: `Preferences` > `Advanced`

2. How can configure your local `kubectl` to point to this newly created cluster?
    [X] `kubectl set-context`
   
3. Now that `kubectl` is pointing to your cluster, what command can you use to check that the cluster indeed has node(s) connected?
    [X] `kubectl get nodes`
   
4. How can we deploy the image for `CatApplication` into the cluster as just a `Pod`?
   - **Hint** - Refer to ["How to create a K8S Pod"](https://www.youtube.com/watch?v=T6E2yzlEX0Q&t=82s)
   [X] `cd kubernetes && kubectl apply -f .`

5. `CatApplication` is serving an endpoint `/cats` on port `8080`. How can we hit this endpoint from your local machine?
   - There are many ways to do this, but for this step, use the simplest approach without creating any new K8S resource
   [X] `kubectl port-forward pod/meow 8080`

6. Run the `disaster.sh` script.
   - Oh no! Disaster struck! Your pod has mysteriously disappeared! If this was a public application, millions of cat lovers would be really sad because they can't see cats now.
   - We need to prevent this from happening! What should we deploy to the cluster to ensure that the `CatApplication` Pods can be **highly available** - has more than one Pod and at least one Pod is up at all times?
   - **Hint** - Refer [here](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#creating-a-deployment) for spec reference 
   
   [X] `curl https://raw.githubusercontent.com/Thoughtworks-SEA-Capability/Infrastructure-101-Pathway/master/week5/disaster.sh --output disaster.sh`
   [X] `chmod u+x disaster.sh`
   [X] `./disaster.sh`
   [X] Change `Pod` resources to `Deployment` resources
   [X] `kubectl apply -f kubernetes/`
   [X] Use `kubectl describe deployment/meow-deployment` to inspect `Replicas` and `StrategyType`

7. Now that you have multiple Pods for `CatApplication`, let's try to hit the `/cats` endpoint again. 
   - How should we choose which Pod's endpoint to hit?
        [] Use `Service` resource? 
   - Since we learnt from `disaster.sh` that Pods may come and go unexpectedly, how can we let Kubernetes help us decide which `CatApplication` Pod to route our request to so that we can reliably get the response that we need?
   - **Hint** - Refer [here](https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/#creating-a-service) for spec reference 

8. Deploy `MeowApplication` in the same way you did for `CatApplication` 
   - Notice that the Pods for `MeowApplication` do not start up healthily. How can you debug why the Pods are not starting up correctly?
   - The Pods are crashing because it is missing a required environment variable configuration `DO_YOU_LIKE_CATS`. How can we add this configuration in?
     - *Even though we can add the env var when we build application or image, for environment specific variables, we should aim to only configure them at the point of deployment.*

9.  `MeowApplication` has an endpoint `/meow` on port `8080`. It works by first calling `CatApplication` internally for the list of cats and then processing their meows.
    - Test out the `/meow` endpoint and debug the problem
    - For ease of testing, can we try out `curl` commands from within a `MeowApplication` Pod to see what works?

10. A new version of `MeowApplication` has just been released! Update your Deployment to use this new image version (`janesee3/meow-application:2`)
    - Aaand of course there're some errors and now your Pods are crashing. How can we rollback your deployment to the older working version?

---