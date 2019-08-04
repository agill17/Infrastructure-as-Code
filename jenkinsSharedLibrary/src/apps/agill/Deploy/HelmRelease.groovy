package apps.agill.Deploy

import apps.agill.Chart
import apps.agill.Constants

class HelmRelease {

    private Script script
    /**
     * releaseName is the name of the helm release
     */
    private String releaseName
    /**
     * namespace defines where a helm release should be installed
     */
    private String namespace
    /**
     * the full-name of valuesFile to use from local file system
     */
    private String valuesFile
    /**
     * if otherArgs like --set, --atomic, etc that are not explicitly defined in helmRelease yet
     */
    private String otherArgs
    /**
     * What tiller to use? -- defaults to kube-system tiller
     */
    private String tillerNamespace = Constants.TILLER_NAMESPACE
    /**
     * Should helm run the install/upgrade command with --dry-run flag on?
     */
    private Boolean dryRun
    /**
     * Should helm run the install/upgrade command with --wait flag on?
     */
    private Boolean wait
    /**
     * Should helm run the install/upgrade command with --debug flag on?
     */
    private Boolean debug
    /**
     * Should helm run the install/upgrade command with --force flag on?
     */
    private Boolean force
    /**
     * What chart should helm install
     */
    private Chart chart
    /**
     * Helm install/upgrade timeout ( defaults to 600 secs )
     */
    private Integer timeout = Constants.HELM_TIMEOUT



    HelmRelease(Script script){
        this.script = script
    }

    /**
     * Performs a helm upgrade install
     * @param config: A map that has fields defined ( from HelmRelease ) to deploy a chart
     */
    void Deploy(Map config) {
        installHelmRelease(castToHelmRelease(config))
    }

    /**
     * Rollback a helm release
     * @param config: A map that has fields defined ( from HelmRelease ) to rollback a helm release
     */
    void RollBack(Map config) {
        rollBackHelmRelease(castToHelmRelease(config))
    }
    /**
     * Deletes a helm release
     * @param config: A map that has fields defined ( from HelmRelease ) to delete a helm release
     */
    void Delete(Map config) {
        deleteHelmRelease(castToHelmRelease(config))
    }

    /**
     * Responsible for type casting a unstructured map to a HelmRelease object
     * So if you other fields that are not present in HelmRelease you will get an error
     * This makes sure no other fields are being passed in, and the incoming data types are verified.
     * Also helps generating docs
     * @param config
     * @return HelmRelease object
     */
    private HelmRelease castToHelmRelease(Map config) {
        HelmRelease release
        try {
            release = (HelmRelease) config
        } catch (error) {
            println("You must pass in a valid release object: ${release.dump()}")
            throw error
        }

        return release
    }

    /**
     * Responsible for installing helm releases
     * @param config
     */
    private void installHelmRelease(HelmRelease release) {
        try{
            String version = release.chart.version != null ? "--version=${release.chart.version}": ""
            String debugMode = release.debug != null ? "--debug" : ""
            String dryRun = release.dryRun != null ? "--dry-run": ""
            String wait = release.wait != null ? "--wait": ""
            String force  = release.force != null ? "--force": ""
            String valuesFile = release.valuesFile != null ? "-f ${release.valuesFile}": ""

            /*
            When rebuild dependency is true, this means this is chart from local file system
             */
            if (release.chart.rebuildDependency) {
                if (!script.fileExists(file: "${release.chart.name}/Chart.yaml")) {
                    throw new FileNotFoundException("${release.chart.name} chart not found on local filesystem to rebuild dependency.")
                }
                // if chart does exist
                script.sh("rm -rf ${release.chart.name}/charts/*.tgz && rm -f ${release.chart.name}/requirements.lock")
                script.sh("helm dep build ${release.chart.name}")
            }

            script.sh "helm upgrade ${release.releaseName} ${release.chart.name} ${version} ${dryRun} ${debugMode} --install ${force} ${valuesFile} --tiller-namespace=${tillerNamespace} ${wait} " +
                    "--timeout=${timeout} ${release.otherArgs}"

        } catch (error) {
            println("Something went wrong when installing helm release: ${error.toString()}")
            throw error
        }
    }

    private void rollBackHelmRelease(HelmRelease release) {
        try {
            script.sh("helm rollback ${release.releaseName} ${release.otherArgs}")
        } catch (error) {
            println("Something went wrong when rolling back your helm release: ${error.toString()}")
            throw  error
        }
    }

    private void deleteHelmRelease(HelmRelease release) {
        try {
            script.sh("helm del --purge ${release.releaseName} ${release.otherArgs}")
        } catch (error) {
            println("Something went wrong when deleting your helm release: ${error.toString()}")
            throw  error
        }
    }

    private Boolean isChartDir(String whichDir)  {
        if (fileExists("${whichDir}/Chart.yaml")) {
            return true
        }
        return false
    }



}

