Creates an autoscaling group using TF/CloudFormation to cleanly replace instances based on health check

Usage:
```
module "ec2_autoscaling" {
  source                 = "github.com/flexera/cloud-enablement/terraform/aws/modules/ec2_autoscaling"
  env                    = "${var.env}"
  app                    = "jenkins" #Application name for ASG identification
  artifact_etag          = "${var.ami_id}" #Unique identifier to application to create new launch configuration, can be AMI_ID or some type of git commit ID, etc
  ami_id                 = "${var.ami_id}"
  instance_type          = "${var.type}"
  iam_profile_name       = "${aws_iam_instance_profile.jenkins.name}"
  security_group_ids     = "${aws_security_group.jenkins.id}"
  rendered_template_file = "${data.template_file.jenkins.rendered}" #EC2 Userdata to apply on start-up
  volume_size            = "${var.volume_size}"
  subnet_ids             = "${var.subnets}"
  max_instances          = "2"
  min_instances          = "1"
  elb_name               = "${aws_elb.jenkins-elb.name}"
  asg_target             = "200" #Target % capacity of autoscaling group to be considered successful
}
