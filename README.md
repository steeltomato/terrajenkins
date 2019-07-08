# TerraJenkins

Simplified AWS Jenkins deployment without managing infrastructure. Runs on ECS with single-use build nodes.

Terraform will create two ECS clusters, one for the master and the other for the build nodes. The build cluster can run 
Fargate or EC2 tasks. If your build script relies on docker, you must use EC2-backed tasks.

### Installation and deployment

* Manual AWS configuration
  * Install SSL Cert and create DNS zone
* Fork this repo and add it as an upstream remote
* Create directory for your environment under env/
  * Set the aws account info in `aws_account.sh`
  * Set the bucket name in `main.tfbackend`
  * Set the appropriate variables in `main.tfvars`
    * You only need to change the acct ID in the ecr_arn variable
* Review the Jenkins master Dockerfile [docker/master/Dockerfile] and add any desired plugins
* Run `./init.sh <aws account>`
  * This creates an S3 bucket to hold terraform state and published a docker image for the Jenkins master node
  * Set the `jenkins_image_tag` variable in main.tfvars to the newly published image tag from the script output
* Deploy stack
  * `./td.sh <aws account> init`
  * `./td.sh <aws account> apply`
  * Wait
  * Save the output variables
* Post-install Configuration
  * Set Base URL
  * Enable CSRF
  * Switch to Matrix-Based security and restrict permissions
  * Prevent builds from running on master
  * Configure security
    * TODO
  * Configure ECS
    * Configure System -> Add a new cloud -> EC2 Container Service Cloud
    * Name: ecs-jenkins-cloud
    * Credentials: none (inherits ecs service/task role)
    * Set region and select cluster <stack>-node-host-cluster
    * Add Fargate ECS Agent Template (doens't support docker builds)
      * Label: ecs-fargate
      * Template Name: jenkins-agent
      * Docker Image: jenkinsci/jnlp-slave or the URI for your custom builder
      * Launch Type: FARGATE
      * Network Mode: awsvpc
      * Filesystem Root: /home/jenkins
      * Soft Memory and CPU: Must be valid combination for Fargate
      * Subnets: Paste from the terraform output
      * Security Groups: Paste from the terraform output
      * Task Execution ARN: Paste from the terraform output
      * Logging Driver: awslogs
      * Logging Config:
        * awslogs-region / us-east-1
        * awslogs-group / [your stack name]
        * awslogs-stream-prefix / jenkins-agent
    * Add EC2-backed Agent Template
      * TODO: Pretty much the same as above just EC2 launch type

### Upgrading Jenkins

* Update the FROM in docker/master/Dockerfile
* Update any desired plugins
* `./publish-image.sh <aws account> master`
* Update `jenkins_image_tag` in all main.tfvars files
* Go into Jenkins and put it into maintenance mode, wait for all builds to stop
* `./td.sh <account name> apply`
* Wait for Jenkins to start back up
* Yeah, that's it.

### Restarting Jenkins

If you just need to restart the Jenkins master (say after manually upgrading a plugin):
* Manage Jenkins -> Prepare for Shutdown
* Wait for jobs to finish
* Sign into AWS Console -> ECS -> Tasks -> Stop the Jenkins Master task
* TODO: Script for this

### Deploying a custom builder agent image

* Create a new builder directory under docker/
* `./publish-image.sh <aws account> <builder name>`

### Backups

* EFS is automatically backed up daily using AWS Backup

### Troubleshooting

* Jenkins writes logs to a CloudWatch log group that matches the stack name
  * This is especially useful to find errors related to launching ECS tasks

### Known Issues and Remaining Tasks

* Outage Alerts
* Update hook to put Jenkins into shutdown mode and wait for jobs to finish
* Pre-populate ECS config in Jenkins settings
