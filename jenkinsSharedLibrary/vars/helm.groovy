import apps.agill.ClosureUtils
import apps.agill.Deploy.HelmRelease


/**
 *
 * @param config example:
 * helm.deploy(
 *   releaseName: "my-release",
 *   namespace: "namespace",
 *   valuesFile: "path/to/local/values.yaml",
 *   otherArgs: "--set image.tag=1.2.0,
 *   debug: true,
 *   force: true,
 *   chart: [
 *     name: stable/<chartName>,
 *     version: 1.0.0,
 *   ]
 * )
 */
void deploy(Map config) {
    ClosureUtils.slackableStage("Helm Deploy") {
        HelmRelease.Deploy(config)
    }

}

void delete(Map config) {
    ClosureUtils.slackableStage("Helm Delete"){
        HelmRelease.Delete(config)
    }
}

void rollback(Map config) {
    ClosureUtils.slackableStage("Helm Rollback"){
        HelmRelease.RollBack(config)
    }
}