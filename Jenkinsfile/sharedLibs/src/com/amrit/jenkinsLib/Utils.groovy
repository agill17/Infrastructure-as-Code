package com.amrit.jenkinsLib

def getCommitId(){
    commitId = sh returnStdout: true, script: 'git rev-parse --short HEAD'
    return commitId
}

def containerRunning(String containerName){
    if (!containerName.empty){
        running = 'docker ps -a'.execute().text.contains(containerName)
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

def pushDockerImage(imgObj, String credentialId, String registry="https://registry.hub.docker.com"){
    docker.withRegistry(registry,credentialId) {
        imgObj.push()
    }
}

def runDockerContainer(String imgName, String args){
    if (!imgName.empty) {
        container = docker.image(imgName).run(args)
        return container
    }
}


def stopDockerContainer(String containerName, containerObj){
    if (containerRunning(containerName)) {
        containerObj.stop()
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

//nexusRepoToUse = "${branchName}-${appName}"
//
//nexusPublisher nexusInstanceId: "172.31.2.11:8081", nexusRepositoryId: "dev-grants", packages: [[$class: 'MavenPackage', mavenAssetList: [[classifier: '', extension: '', filePath: 'target/grants.war']], mavenCoordinate: [artifactId: 'grants', groupId: 'com.uts.grants', packaging: 'war', version: '1.1.0']]]

def pushArtifactToNexus(String version, String artifactPath, String artifactId, String groupId, String nexusRepo, String nexusServerIp="172.31.2.11:8081", String packageType='war'){
    if (!(artifactPath.empty && nexusRepo.empty &&
            nexusServerIp.empty && version.empty &&
            artifactId.empty && groupId.empty && nexusRepo.empty))
    {
        nexusPublisher(nexusInstanceId: nexusServerIp,
                nexusRepositoryId: nexusRepo,
                packages: [[$class: 'MavenPackage', mavenAssetList: [[classifier: '', extension: '', filePath: artifactPath]],
                            mavenCoordinate: [artifactId: artifactId, groupId: groupId, packaging: packageType, version: version]]])
    }
}
