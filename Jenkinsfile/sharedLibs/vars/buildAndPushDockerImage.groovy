import com.amrit.jenkinsLib.Constants
import com.amrit.jenkinsLib.Utils

def call(Map config) {

    def utils = new Utils()

    def imgName = config.imgName ?: 'agill17/imagefromjenkinsfile'
    def buildArgs = config.buildArgs
    def credential_id = config.dockerCredentialId ?: Constants.DOCKER_CRED_ID
    def registry = config.registry  ?: Constants.DOCKER_PUBLIC_REGISTRY

    utils.dockerBuildAndPush(imgName,buildArgs,credential_id,registry)


}