package com.amrit.jenkinsLib

def getCommitId(){
    commitId = sh returnStdout: true, script: 'git rev-parse --short HEAD'
    return commitId
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
  docker.image(imgName).inside {
    cmds.each { x -> 
      sh x
    }
  }
}

def buildDockerImage(String imgName, String args){
    image = docker.build(imgName, args)
    return image
}

def isImageAvailLocally(String whichImage){
    def localImages = 'docker images'.execute().getText()
    if localImages.contains(whichImage){
        return true
    } else {
        return false
        println "The image you specified --> ${whichImage} <-- is not available on: ${env.NODE_NAME}"
    }
}

def pushDockerImage(String whichImage, String credentialId, String registry="https://registry.hub.docker.com",imgObj){

    def useImageObj = (imgObj != null || !imgObj.empty) ? true : false

    if (useImageObj){
        docker.withRegistry(registry, credentialId){
            imgObj.push()
        }   
    } else if (!whichImage.empty && whichImage != null && isImageAvailLocally(whichImage) == true) {
        sh(returnStdout: true, script: "docker push whichImage")
    } else {
        println "You must pass in Image name as first parameter or the image object as the last parameter"
    }
}

def runDockerContainer(String imgName, String args){
    if (!imgName.empty) {
        container = docker.image(imgName).run(args)
        return container
    }
}


def stopDockerContainer(String containerName, containerObj){
    if (containerName.empty || containerName ==null){
        System.exit(1)
    }

    isRunning = containerRunning(containerName)


    if (!containerObj.empty && containerObj != null && isRunning){
        containerObj.stop()
    } else {
        sh(returnStdout: true, script: "docker rm -f ${containerName}")
    }
   
}

def getMvnAppVersion(String pomFile) {
    file = new File(pomFile)
    println(file.exists())
    if (file.exists()){
        def parser = new XmlParser().parse(file)
        return parser.version.text()
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

def pushArtifactToNexus(String version, String artifactPath, String artifactId, String groupId, String nexusRepo, String nexusServerIp, String packageType='war'){
    repoId = (nexusRepo.empty) ? Constants.NEXUS_REPO : nexusRepo
    nexusIp = (nexusServerIp.empty) ? Constants.NEXUS_URL : nexusServerIp
    nexusPublisher(nexusInstanceId: nexusIp, nexusRepositoryId: repoId,
                  packages: [[$class: 'MavenPackage', mavenAssetList: [[classifier: '', extension: '', filePath: artifactPath]],
                  mavenCoordinate: [artifactId: artifactId, groupId: groupId, packaging: packageType, version: version]]])
}

