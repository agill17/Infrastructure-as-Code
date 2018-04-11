# 101

#### Every pipeline begins with node {}
#### Pipelines consists of stages
#### stages consists of what you want to do per stage
#### stage examples; build, test, code quality, upload to artifactory, provision, deploy, cleanup etc

#### Every tool you configure in Manage Jenkins -> Configure Global tool; is available to use in pipelines
#### Just specify tool name: '< name that you gave while configuring >'
#### Maybe assign to a varibale outside stages and use it in every stage
#### def mvn = tool name: 'MAVEN' -- then in stage you may have a step; sh "${mvn}/bin/mvn clean"
#### To switch dir in pipeline; you can use dir(dir_name)

#### Most importantly - you can use any groovy logic/functions/classes to programmatically do something