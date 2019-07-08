stack               = "jenkins"
region              = "us-east-1"
zones               = [
  "us-east-1a",
  "us-east-1b",
  "us-east-1c"]

vpc                 = "vpc-..."
public_subnets      = [
  "subnet-..."]
private_subnets     = [
  "subnet-..."]

ssl_certificate_arn = "arn:aws:acm:us-east-1:123456789:certificate/..."
route_zone_id       = "..."

domain_name         = "jenkins.mydomain.com"

ecr_arn             = "arn:aws:ecr:us-east-1:123456789:repository/jenkins/master"

ec2_instance_type       = "t3.small"
node_host_instance_type = "t3.xlarge"

jenkins_repository  = "jenkins/master"
jenkins_image_tag   = "2019-06-25_10-17"

// CIDR block permitted to connect to the Jenkins master over SSH or JNLP
// This should be strongly restricted
jnlp_whitelist      = []
