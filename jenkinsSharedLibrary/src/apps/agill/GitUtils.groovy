package apps.agill

class GitUtils implements Serializable {

    private Script script

    GitUtils(script) {
        this.script = script
    }

    /**
     *
     * @return env.BRANCH_NAME
     */
    String getRawBranchName() {
        return script.env.BRNACH_NAME
    }

    /**
     *
     * @return the underlying branch name of a pullRequest
     */
    String getPrBranchName() {
        return script.env.CHANGE_BRANCH
    }

    /**
     *
     * @return the target branch this pr is open for
     */
    String getPRTargetBranchName() {
        return script.env.CHANGE_TARGET
    }

    /**
     * @return gets branch type incase you are following a branch naming strategy ( like feature, release, fix )
     */
    String getBranchType() {
        return getBranchName().split("/")[0]
    }

    /**
     * @return returns the first 8 characters of git commit sha
     */
    String getShortCommitSha() {
        return script.sh(script: "git rev-parse --short HEAD", returnStdout: true)
    }

    /**
     * @return if branch is a PullRequest
     */
    Boolean isBranchAPr() {
        if (env.CHANGE_ID) {
            return true
        }
        return false
    }

    /**
     * Gets the branch name, given this is running inside a git context
     * @return branch name even if its a PR
     */
    String getBranchName() {


        if (isBranchAPr()) {
            getPrBranchName()
        }

        return getRawBranchName()
    }




}

