#!/bin/bash

deploy() {

	kubectl apply -f deployment/

}

clean() {
	kubectl delete deployment $(kubectl get deployment --selector=$sel --output=jsonpath={.items..metadata.name})
 	kubectl delete svc $(kubectl get svc --selector=$sel --output=jsonpath={.items..metadata.name})
 	kubectl delete secrets $(kubectl get secrets --selector=$sel --output=jsonpath={.items..metadata.name})
 	kubectl delete configMap $(kubectl get configMap --selector=$sel --output=jsonpath={.items..metadata.name})

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
