package com.amrit.jenkinsLib

import groovy.json.JsonSlurper
import jdk.nashorn.internal.parser.JSONParser


class Utils implements Serializable {
  
    def script

  
    Utils(script){
        this.script = script
    }

    // Most of these methods will really work on multi-branch jobs

    def getCommitId(){
        commitId = script.sh returnStdout: true, script: 'git rev-parse --short HEAD'
        return commitId
    }

    def getGitRepoName() {
        def repoName = script.sh(returnStdout: true, script: "git config --get remote.origin.url").split('/')[-1].replaceAll('.git', '')
        return repoName
    }

    // if you have branch naming convention like, feature/JIRA-123, bugFix/JIRA-123, release/1223
    // then this can be handy
    def getBranchType(Map config) {
        def delimeter = config.delimeter ?: '/'
        return env.BRANCH_NAME.split('/')[0]
    }

    def stdGitInfo(){
        return [gitRepo: getGitRepoName(), branch: env.BRANCH_NAME, branchType: getBranchType()]
    }

    def parseJSONFile(Map config){
        if (new File(config.file).exists()) {
            def parser = new JsonSlurper().parse(config.file)
            return parser
        } else {
            println("No such File or Directory: $config.file")
        }
    }

    def versionDockerImage(String extraTag){
        def tag = env.BUILD_TAG
        if (extraTag){
            tag += "-${extraTag}"
        }
         return tag
    }

    def getValueFromPropertyFile(Map config){
        if (!config.file && !config.lookUpValue){
            if (new File(config.file).exists()){
                def parser = script.readProperties file: config.file
                return parser.${config.lookUpValue}
            } else{
                println("No such file!! " + config.file)
            }
        }
    }


    def parseJSONText(Map config) {
        if (config.text == null || config.text.toString().isEmpty() ){
            def parser = new JsonSlurper().parseText(config.text)
            return parser
        }
    }


    def containerRunning(String containerName){
        if (!containerName.empty){
            running = 'docker ps -a'.execute().getText().contains(containerName)
            println "Is ${containerName} container running and or stopped: ${running}"
            if (running){
                return true
            }
            else{
                return false
            }
        }
    }

    def mvnBuildCommands(def cmds=["mvn package"], String imgName="maven:latest"){
        script.docker.image(imgName.inside {
            cmds.each { x ->
                sh x
            }
        }
    }

    def buildDockerImage(String imgName, String args){
        image = script.docker.build(imgName, args)
        return image
    }

    def isImageAvailLocally(String whichImage){
        def localImages = 'docker images'.execute().getText()
        if (localImages.contains(whichImage)){
            return true
        } else {
            return false
            println "The image you specified --> ${whichImage} <-- is not available on: ${env.NODE_NAME}"
        }
    }

    def pushDockerImage(String whichImage, String credentialId, String registry="https://registry.hub.docker.com",imgObj){

        def useImageObj = (imgObj != null || !imgObj.empty) ? true : false

        if (useImageObj){
            script.docker.withRegistry(registry, credentialId){
                imgObj.push()
            }
        } else if (!whichImage.empty && whichImage != null && isImageAvailLocally(whichImage) == true) {
            script.sh(returnStdout: true, script: "docker push whichImage")
        } else {
            println "You must pass in Image name as first parameter or the image object as the last parameter"
        }
    }

    def runDockerContainer(String imgName, String args){
        if (!imgName.empty) {
            container = steps.docker.image(imgName).run(args)
            return container
        }
    }

    def containerAction(String containerName, String action){
        if (!containerName.empty() || !action.empty() && containerRunning(containerName) ) {
            switch(action) {
                case ['stop', 'Stop']:
                    stopDockerContainerByName(containerName)
                    break;
                case ['rm', 'Rm', 'remove', 'Remove']:
                    rmDockerContainerByName(containerName)
                    break;
            }
        } else if ( !containerRunning(containerName)) {
            println "SKIP - $containerName container is not running..."
        } else {
            println "containerName arguement was not passed or was null...."
            S
        }
    }


    def stopDockerContainerByName(String containerName){
        isRunning = containerRunning(containerName)
        script.sh(returnStdout: true, script: "docker stop ${containerName}").trim()

    }

    def rmDockerContainerByName(String containerName){
        isRunning = containerRunning(containerName)
        script.sh(returnStdout: true, script: "docker stop ${containerName}").trim()
    }

    def rmAllContainers(){
        zombiePlusRunning = script.sh(returnStdout: true, script: 'docker ps -aq').trim()
        if (!zombiePlusRunning.empty()){
            println "Stopping and removing these containers --> $zombiePlusRunning"
            zombiePlusRunning.tokenize().each() { c ->
                sh "docker stop $c"
                println "Stopped container --> $c"
                sh "docker rm $c"
                println "Removed container --> $c"
            }
        }
    }

    def getMvnAppVersion(Map config) {
        if (new File(config.pomFile).exists()){
            def parser = new XmlParser().parse(config.pomFile)
            return parser.version.text()
        } else {
            println("No such file: $config.pomFile")
        }
    }

    def dockerBuildAndPush(String imgName, String buildArgs, String credentialId, String registry="https://registry.hub.docker.com" ){
        image = buildDockerImage(imgName, buildArgs)
        pushDockerImage(image,credentialId,registry)
        return image.id
    }

    def deleteImage(imgObj){
        "docker rmi ${imgObj.id}".execute().getText()
    }

    def pushArtifactToNexus(Map config){
        def repoId = config.repo ?: Constants.NEXUS_REPO
        def nexusIp = config.nexusURL ?: Constants.NEXUS_URL
        def packageType = config.packageType ?: 'war'
        def version = config.version ?: getMvnAppVersion(pomFile: 'pom.xml')
        nexusPublisher(nexusInstanceId: nexusIp, nexusRepositoryId: repoId,
                packages: [[$class: 'MavenPackage', mavenAssetList: [[classifier: '', extension: '', filePath: config.artifactPath]],
                            mavenCoordinate: [artifactId: config.artifactId, groupId: config.groupId, packaging: packageType, version: config.version]]])
    }


}
