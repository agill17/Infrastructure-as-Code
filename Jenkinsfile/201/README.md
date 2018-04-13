##### Do not try to use env.BRANCH_NAME in a regular pipeline job.
##### That syntax only works in Multibranch pipeline jobs

##### back to global tool configuration;
##### for nodejs thats already configured then, you can use
###### nodejs('nodejs_configuration_name') { sh "npm commands" }

##### This jenkins file ideal goal was to build / push and run docker images
##### with docker pipeline plugin being installed; you can use inbuilt methods
###### docker.build('image_name:tag', "build_args_for_ARGS -f <DockerfileName> /path/to/Dockerfile")
##### if Dockerfile is in the root/currentDir then just specifying "." works and it would look like;
###### docker.build('image_name:tag', "build_args_for_ARGS -f Dockerfile .")


##### with Docker pipeline plugin you can also push to docker hub or private registry as long as you have credentials configured.
###### docker.withRegistry("url", "cred_id") { 
######	def img = docker.build('image_name:tag', "build_args_for_ARGS -f Dockerfile .")
###### 	img.push()	
###### }


##### you can run sh "" steps to run and stop docker containers