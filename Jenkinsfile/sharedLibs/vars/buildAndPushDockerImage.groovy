
def call(body) {

    def utils = new com.amrit.jenkinsLib.Utils()


    // evaluate the body block, and collect configuration into the object
    def config = [:]
    body.resolveStrategy = Closure.DELEGATE_FIRST
    body.delegate = config
    body()

    imgName = config.imgName
    buildArgs = config.buildArgs
    credential_id = config.credential_id
    registry = (config.registry == null || config.registry.empty)  ? "https://registry.hub.docker.com" : config.registry

    def image = utils.dockerBuildAndPush(imgName,buildArgs,credential_id,registry)
    return image
}