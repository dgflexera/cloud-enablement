resource "aws_launch_configuration" "ec2" {
  name_prefix                 = "${var.app}_${var.env}_${var.artifact_etag}"
  associate_public_ip_address = false
  image_id                    = "${var.ami_id}"
  instance_type               = "${var.instance_type}"
  iam_instance_profile        = "${var.iam_profile_name}"
  security_groups             = ["${split(",", var.security_group_ids)}"]
  user_data                   = "${var.rendered_template_file}"

  root_block_device = {
    delete_on_termination = true
    volume_size           = "${var.volume_size}"
  }

  lifecycle {
    create_before_destroy = true 
  }
}

resource "aws_cloudformation_stack" "autoscaling_group" {
  name = "${var.app}-${var.env}"

  template_body = <<EOF
{
  "Resources": {
    "${replace(var.app,"-","")}ASG${var.env}": {
      "Type": "AWS::AutoScaling::AutoScalingGroup",
      "Properties": {
        "VPCZoneIdentifier": ["${var.subnet_ids}"],
        "LaunchConfigurationName": "${aws_launch_configuration.ec2.name}",
        "MaxSize": "${var.max_instances}",
        "MinSize": "${var.min_instances}",
        "LoadBalancerNames": ["${var.elb_name}"],
        "TerminationPolicies": ["OldestLaunchConfiguration", "OldestInstance"],
        "HealthCheckType": "ELB",
        "HealthCheckGracePeriod": "${var.healthcheck_grace_period}",
        "Tags" : [
          { "Key" : "Name", "Value" : "${var.app}", "PropagateAtLaunch" : "true" },
          { "Key" : "env", "Value" : "${var.env}", "PropagateAtLaunch" : "true" },
          { "Key" : "app", "Value" : "${var.app}", "PropagateAtLaunch" : "true" },
          { "Key" : "etag", "Value" : "${var.artifact_etag}", "PropagateAtLaunch" : "true" }
        ]
      },
      "UpdatePolicy": {
        "AutoScalingRollingUpdate": {
          "MinInstancesInService": "${var.min_instances}",
          "MaxBatchSize": "${var.batch_size}",
          "PauseTime": "PT${var.pause_time_minutes}M"
        }
      }
    },
    "${replace(var.app,"-","")}ASGPOLICY": {
      "Type": "AWS::AutoScaling::ScalingPolicy",
      "Properties": {
        "AutoScalingGroupName": { "Ref": "${replace(var.app,"-","")}ASG${var.env}" },
        "AdjustmentType": "ChangeInCapacity",
        "Cooldown": "${var.autoscale_cooldown}",
        "PolicyType": "TargetTrackingScaling",
        "TargetTrackingConfiguration": {
          "PredefinedMetricSpecification": {
            "PredefinedMetricType": "${var.asg_metric}"
          },
        "TargetValue": "${var.asg_target}"
        }
      }
    }
  }
}
EOF
count = "${var.lb_type == "elb" ? 1: 0}"
}

resource "aws_cloudformation_stack" "autoscaling_group_alb" {
  name = "${var.app}-${var.env}"

  template_body = <<EOF
{
  "Resources": {
    "${replace(var.app,"-","")}ASG${var.env}": {
      "Type": "AWS::AutoScaling::AutoScalingGroup",
      "Properties": {
        "VPCZoneIdentifier": ["${var.subnet_ids}"],
        "LaunchConfigurationName": "${aws_launch_configuration.ec2.name}",
        "MaxSize": "${var.max_instances}",
        "MinSize": "${var.min_instances}",
        "TargetGroupARNs" : ["${var.alb_target_groups}"],
        "TerminationPolicies": ["OldestLaunchConfiguration", "OldestInstance"],
        "HealthCheckType": "ELB",
        "HealthCheckGracePeriod": "${var.healthcheck_grace_period}",
        "Tags" : [
          { "Key" : "Name", "Value" : "${var.app}", "PropagateAtLaunch" : "true" },
          { "Key" : "env", "Value" : "${var.env}", "PropagateAtLaunch" : "true" },
          { "Key" : "app", "Value" : "${var.app}", "PropagateAtLaunch" : "true" },
          { "Key" : "etag", "Value" : "${var.artifact_etag}", "PropagateAtLaunch" : "true" }
        ]
      },
      "UpdatePolicy": {
        "AutoScalingRollingUpdate": {
          "MinInstancesInService": "${var.min_instances}",
          "MaxBatchSize": "${var.batch_size}",
          "PauseTime": "PT${var.pause_time_minutes}M"
        }
      }
    },
    "${replace(var.app,"-","")}ASGPOLICY": {
      "Type": "AWS::AutoScaling::ScalingPolicy",
      "Properties": {
        "AutoScalingGroupName": { "Ref": "${replace(var.app,"-","")}ASG${var.env}" },
        "AdjustmentType": "ChangeInCapacity",
        "Cooldown": "${var.autoscale_cooldown}",
        "PolicyType": "TargetTrackingScaling",
        "TargetTrackingConfiguration": {
          "PredefinedMetricSpecification": {
            "PredefinedMetricType": "${var.asg_metric}"
          },
        "TargetValue": "${var.asg_target}"
        }
      }
    }
  }
}
count = "${var.lb_type == "alb" ? 1: 0}"

EOF
}

