import com.amrit.jenkinsLib.Constants
import com.amrit.jenkinsLib.Utils

def call(Map config) {
    /*
        When calling methods from src/ make sure to pass this as constructor value
        It enables src methods to utilize basically all steps from pipeline that are built in
    */

    def utils = new Utils(this)

    def imgName = config.imgName ?: 'agill17/imagefromjenkinsfile'
    def buildArgs = config.buildArgs
    def credential_id = config.dockerCredentialId ?: Constants.DOCKER_CRED_ID
    def registry = config.registry  ?: Constants.DOCKER_PUBLIC_REGISTRY

    utils.dockerBuildAndPush(imgName,buildArgs,credential_id,registry)


}
