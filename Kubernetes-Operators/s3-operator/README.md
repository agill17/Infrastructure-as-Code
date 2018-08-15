# Deploying to cluster
  ```
  1. kubectl apply -f example/operator.yaml
  2. kubectl apply -f example/cr.yaml
  ```
  
  ### Note: 
  1. If namespace CR was deployed in is deleted, the s3 bucket gets deleted.
  2. If the CR from the namespace is deleted, the s3 bucket gets deleted
----

## TODO

#### 1. S3 sync
