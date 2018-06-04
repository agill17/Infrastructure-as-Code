#!/bin/bash

NAMESPACE=$2


deploy() {

	kubectl apply -f deployment/namespace.yml
	kubectl apply -f deployment/storage-class.yml
	kubectl apply -f deployment/persistentVolumeClaim.yml
	kubectl apply -f deployment/db_configMap.yml
	kubectl apply -f deployment/db_creds.yml
	kubectl apply -f deployment/db_deployment.yml
	kubectl apply -f deployment/db_svc.yml
	kubectl apply -f deployment/app_deployment.yml
	kubectl apply -f deployment/app_svc.yml

}

clean() {
	echo "Deleting resources under $NAMESPACE namespace"
	kubectl delete namespace $NAMESPACE
}



case $1 in 
	deploy)
		deploy
		;;
	clean)
		clean
		;;
esac


### should really just namespaces but for now its fine...
