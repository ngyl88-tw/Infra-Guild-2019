# Kubernetes
---
## Week 5

#### Steps

1. Start a Kubernetes cluster on your local machine using Docker
   - Enable it here: `Preferences` > `Kubernetes` 
   - You may want to temporarily increase the Memory and CPU allocated for Docker for better performance: `Preferences` > `Advanced`

2. How can configure your local `kubectl` to point to this newly created cluster?
    [X] `kubectl config set-context`
   
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
   - Since we learnt from `disaster.sh` that Pods may come and go unexpectedly, how can we let Kubernetes help us decide which `CatApplication` Pod to route our request to so that we can reliably get the response that we need?
   - **Hint** - Refer [here](https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/#creating-a-service) for spec reference
   
   [X] Use `Service` resource?
        - Kubernetes `ServiceTypes` defaults to `ClusterIP`, if not specified.  
        - By default, the targetPort is set to the same value as the port field.
        - Value `ClusterIP` makes the Service only reachable from within the cluster. Need `port-forwarding`.

8. Deploy `MeowApplication` in the same way you did for `CatApplication` 
   - Notice that the Pods for `MeowApplication` do not start up healthily. How can you debug why the Pods are not starting up correctly?
   - The Pods are crashing because it is missing a required environment variable configuration `DO_YOU_LIKE_CATS`. How can we add this configuration in?
     - *Even though we can add the env var when we build application or image, for environment specific variables, we should aim to only configure them at the point of deployment.*
     
   [X] Duplicate resources to try deployment of `MeowApplication` 
   [X] Check if MeowApplication healthy, why crash??
        - Pod status `CrashLoopBackOff`, default restarts 4 times. Run `kubectl describe <POD_NAME>` to inspect.
        - To debug, run `kubectl logs -f <POD_NAME>`.
   [X] Update env in `Deployment` pod spec `containers[*].spec`.

9.  `MeowApplication` has an endpoint `/meow` on port `8080`. It works by first calling `CatApplication` internally for the list of cats and then processing their meows.
    - Test out the `/meow` endpoint and debug the problem
    - For ease of testing, can we try out `curl` commands from within a `MeowApplication` Pod to see what works?
    
    [X] `kubectl port-forward service/meow-service 8081` and `curl localhost:8081/meow`
        - To list existing environment variables in pod, run `kubectl exec -it <MEOW_POD> env`
        - To check runtime env injection: `kubectl set env deployment/meow-deployment --list`
    [X] Fixes by rolling update
        - `kubectl set env deployment/meow-deployment CATS_URL=http://cat-service:8080/cats`
        - will see `Error: No such container` in existing port-forwarding, restart the service
    [X] Update env in `Deployment` pod spec, add `CATS_URL` in `containers[*].spec`
   
10. A new version of `MeowApplication` has just been released! Update your Deployment to use this new image version (`janesee3/meow-application:2`)
    - Aaand of course there're some errors and now your Pods are crashing. How can we rollback your deployment to the older working version?

    [X] `kubectl set image deployment/meow-deployment meow=janesee3/meow-application:2 [--record=true]`
    [X] `kubectl rollout history deployment/meow-deployment`
        - output: { REVISION,  CHANGE-CAUSE }
        - CHANGE-CAUSE will be populated with `kubectl set image` when running with `--record=true` option 
    [X] `kubectl rollout undo deployment/meow-deployment [--to-revision=1]`
    [X] `kubectl rollout status -w deployment/meow-deployment` # watch the status of the latest rollout
---
## Week 6

#### Steps

0. Spin up VPC, EKS
    [X] Verify by running `aws eks --region region update-kubeconfig --name cluster_name` and `kubectl get nodes`

1. Creating a Helm chart
    [X] CatApplication
    [X] MeowApplication
    
    - Running `helm create meow-application` will create 
        - `values.yaml` with a bunch of defaulted values
        - ingress and service
        - deployment containers with livenessProbe

2. Initialise helm in your EKS cluster

   In Helm 2, there is a server-side component known as `Tiller`, which is to be installed in the kubernetes cluster you're working on. However, in Helm 3, they've removed the need for a server-side component, so you do not have to bother youself much with Tiller moving forward.
   Simply follow the steps below to initialise `helm` with Tiller, and move on to the next step!

   [] Download / copy the contents of the [`helm/helm-rbac.yaml`](./helm/helm-rbac.yaml) into your machine.
   [] Run `kubectl apply -f helm-rbac.yaml` to install the required K8S ServiceAccount for the Tiller component that will be running in your cluster.
   [] Run `helm init --service-account=tiller`
   [] See [here](https://devopscube.com/install-configure-helm-kubernetes/) if you want to understand more about this init process!

3. Install `CatApplication` and `MeowApplication` as Helm releases into the cluster.
   **Tip:** See [here](https://v2.helm.sh/docs/helm/#helm-install) for information about the `helm install` command.
   **Bonus**: What flags can you add to the `helm install` command to ensure that `helm` will rollback whatever resources that were created in the event that the deployment was unsuccessful? (eg. Pods not starting up healthily) 
   - You may have noticed that the `readinessProbe` setting is configured for the Pods. This means that we no longer have to manually call the `/meow` or `/cats` endpoint ourselves to check for the Pod's health; we can just rely on the Pod's `READY` metric.

   [] Helm installs

4. Yay! `CatApplication` and `MeowApplication` is now running on the cloud! Now, we could hit the `/meow` endpoint using the `port-forward` method last week, but since we're running on the cloud now, how can we expose these endpoints to the internet?

   First, we need to setup a Load Balancer on AWS to receive traffic from the internet and propagate them to the K8S worker nodes accordingly. Next, we need to write routing rules so that we can provide a mapping between the URL paths and our K8S Services.

   Lucky for us, an `Ingress Controller` is what we need to achieve this! There are many Ingress Controllers out there, but for today, we will be using the NGINX Ingress Controller. See here for more information about

   Using the [`nginx-ingress-controller`](https://github.com/helm/charts/tree/master/stable/nginx-ingress) Helm chart, install an ingress controller in your cluster
   - **Tip:** Refer to [this documentation](https://kubernetes.github.io/ingress-nginx/user-guide/basic-usage/) for guide
   - **Tip:** You can use `helm get manifest <release-name>` command to check what K8S resources were created for that release.
   - How can you check what Load Balancer URL has been provisioned for you after the installation? Remember that we can provision an AWS Load Balancer for the EKS cluster by creating a K8S Service with type `LoadBalancer`.
  
5. Next, write the routing rules that will be consumed by the Ingress Controller.
   - **Tip:** These routing rules are actually a type of K8S resource, called `Ingress`. See [here](https://kubernetes.io/docs/concepts/services-networking/ingress/#types-of-ingress) and [here](https://www.youtube.com/watch?v=VicH6KojwCI) for more information!
   - **Tip:** We want to create TWO separate `Ingress` resources, one each for the `CatApplication` and `MeowApplication`, so as to achieve **host-based routing** for the `/meow` and `/cats` endpoints. See [here](https://kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/) for reference.
   - **Tip:** Where should the `Ingress` YAML files be stored in, and how can they be applied to the cluster? See [here](https://v2.helm.sh/docs/helm/#helm-upgrade) for reference.
   - Test that your Ingress resources are correct with `curl` or accesing the endpoint directly from the browser! 

6. How can we deploy the `CatApplication` and `MeowApplication` in a LOCAL kubernetes cluster by reusing the same Helm charts?
   - **Requirements for the local deployment:**
      1. No `Ingress` resources are required, since we will not have an Ingress Controller for a local cluster
      2. `CatApplication` will be using the image `janesee3/cat-application:local`
   - If you haven't already, start up a local Kubernetes cluster using Docker Desktop. Remember to configure your `kubectl` to point to the local cluster afterwards!
   - **Tip:** You will need to create a separate Helm values file (eg. `local-cluster.yaml`)
   

### Extra Activities

1. How can we decouple the configurations for application environment variables from the `Deployment` YAML template, and move them to the `values.yaml` file instead?
   - In doing so, we can easily configure different env vars for the Helm release by switching out a different values file.

2. Try to secure the LoadBalancer URL provisioned by the NGINX Ingress Controller with basic authentication by following this guide [here](https://kubernetes.github.io/ingress-nginx/examples/auth/basic/)
