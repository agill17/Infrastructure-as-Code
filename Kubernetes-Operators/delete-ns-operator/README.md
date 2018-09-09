# Deploying to cluster
  ```
  kubectl apply -f example/operator.yaml
  kubectl apply -f example/cr.yaml
  ```
----
### Note:
  - By default this operator will poll for namespaces every 30 seconds, but can be changed.

#### Want to change how often to poll? 
  - If the operator is already deployed ( This will delete the existing pod in the deployment and create a new one );
    - Change the env variable RESYNC_PERIOD in the deployment 
    ```
    kubectl edit deployment -n operator delete-ns-operator
    ```
  - If the operator is not yet deployed;
    - Change the env variable RESYNC_PERIOD in example/operator.yaml

---
#### How the operator works and the available parameters
  - saveIfAnnotationHas.key and saveIfAnnotationHas.value (string) - Exclude namesapces that have these key,val pair in their annotations.
  - olderThan (int) - This number tells the operator if selected namespaces ( excluding the ones from above ) is older than or equal to x hours, delete it.
  - dryRun (bool) - Can be turned on to just see what will happen, no namespace will be deleted if this is set to true
