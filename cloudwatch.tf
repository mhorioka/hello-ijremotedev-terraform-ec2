resource "aws_cloudwatch_dashboard" "remotedev_dashboard" {
  dashboard_name = "remotedev-dashboard"

  dashboard_body = <<EOF
{
    "widgets": [
        {
            "type": "metric",
            "x": 3,
            "y": 0,
            "width": 6,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/EC2", "CPUUtilization", "InstanceId", "${aws_instance.remotedev_ec2.id}" ]
                ],
                "region": "${var.aws_region}",
                "title": "CPU Utilization"
            }
        },
        {
            "type": "metric",
            "x": 9,
            "y": 0,
            "width": 6,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "CWAgent", "mem_used_percent", "host", "${aws_instance.remotedev_ec2.private_dns}" ],
                    [ ".", "swap_used_percent", ".", "." ]
                ],
                "region": "${var.aws_region}",
                "title": "Memory Utilization"
            }
        },
        {
            "type": "metric",
            "x": 15,
            "y": 0,
            "width": 6,
            "height": 6,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "CWAgent", "disk_used_percent", "path", "/", "host", "${aws_instance.remotedev_ec2.private_dns}", "device", "nvme0n1p1", "fstype", "xfs" ]
                ],
                "region": "${var.aws_region}",
                "title": "Disk Utilization"
            }
        }
    ]
}
EOF
}

data "aws_caller_identity" "self" { }

resource "aws_cloudwatch_metric_alarm" "shutdown_when_idle" {
  alarm_name          = "Shutdown EC2 when idle"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.cloudwatch_cpu_eval_periods
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = var.cloudwatch_cpu_eval_period
  dimensions = {
    InstanceId = aws_instance.remotedev_ec2.id
  }
  statistic                 = "Average"
  threshold                 = var.cloudwatch_cpu_utilization_threshold
  alarm_actions = [
    "arn:aws:swf:${var.aws_region}:${data.aws_caller_identity.self.account_id}:action/actions/AWS_EC2.InstanceId.Stop/1.0"
  ]

  actions_enabled = var.cloudwatch_alarm_action_enabled

}
