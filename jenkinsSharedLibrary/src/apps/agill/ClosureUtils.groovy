package apps.agill

class ClosureUtils {

    private script

    ClosureUtils(script) {
        this.script = script
    }

    void tryCatchBlock(Closure block) {
        try {
            block()
        } catch (err) {
            script.error "ERROR: ${err}"
        }
    }

    void slackableStage(String stageName, Closure slackableStageBlock) {
        script.Stage(stageName) {
            try {
                slackableStageBlock()
            } catch(err) {
                println("ERROR: ${err}")
                throw err
            }
        }
    }

    void WithinContainer(String containerName, Closure withinContainerBlock) {
        script.container(containerName) {
            tryCatchBlock {
                withinContainerBlock()
            }
        }
    }
}
