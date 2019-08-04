import apps.agill.ClosureUtils
import apps.agill.Constants
import apps.agill.DockerImage

void build(DockerImage dockerImage) {
    ClosureUtils clsUtils = new ClosureUtils(this)

    clsUtils.WithinContainer('docker') {
        dockerFileLocation = dockerImage.dockerfilePath ?: Constants.DEFAULT_DOCKER_FILE

        if (!fileExists(file: dockerFileLocation)) {
            throw Error("DockerFileNotFound")
        }

        sh "docker build -t ${dockerImage.fullImageName} -f ${dockerFileLocation}"
    }

}

void push(DockerImage dockerImage) {
    ClosureUtils clsUtils = new ClosureUtils(this)
    clsUtils.WithinContainer('docker') {
        sh "docker push ${dockerImage.fullImageName}"
    }
}

void pull(DockerImage dockerImage) {
    ClosureUtils clsUtils = new ClosureUtils(this)
    clsUtils.WithinContainer('docker') {
        sh "docker pull ${dockerImage.pullFromImageName}"
    }
}

void retag(DockerImage dockerImage) {
    ClosureUtils clsUtils = new ClosureUtils(this)
    clsUtils.WithinContainer('docker') {
        sh "docker tag ${dockerImage.pullFullImageName} ${dockerImage.fullImageName}"
    }
}

void buildAndPush(String pushToRegistry, String fullImageName, String dockerfilePath = Constants.DEFAULT_DOCKER_FILE) {

    // create a new dockerImage obj and set up properties
    DockerImage dockerimage = new DockerImage()
    dockerimage.pushToRegisrty = pushToRegistry
    dockerimage.dockerfilePath = dockerfilePath
    dockerimage.fullImageName = fullImageName

    build(dockerimage)
    push(dockerimage)

}


void pullRetagPush(String pullFullImageName, String pushFullImageName) {

    DockerImage dockerImage = new DockerImage()
    dockerImage.pullFullImageName = pullFullImageName
    dockerImage.fullImageName = pushFullImageName

    pull(dockerImage)
    retag(dockerImage)
    push(dockerImage)


}

