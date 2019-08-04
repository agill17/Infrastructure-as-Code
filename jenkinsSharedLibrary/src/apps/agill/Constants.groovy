package apps.agill

class Constants implements Serializable {

    static ARTIFACTORY_URL = ""
    static NEXUS_URL = ""
    static GIT_CREDENTIALS_ID = ""
    static IMAGE_PULL_SECRETS = ["myprivate-registry.com"]
    static DEFAULT_DOCKER_FILE = "Dockerfile"
    static TILLER_NAMESPACE = "kube-system"
    static HELM_TIMEOUT = 600

}