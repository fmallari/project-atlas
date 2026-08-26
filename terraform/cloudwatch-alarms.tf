resource "aws_cloudwatch_metric_alarm" "project_atlas_disk_usage" {
  alarm_name        = "project-atlas-high-disk-usage"
  alarm_description = "Alerts when Project Atlas root disk usage exceeds 80%."
  namespace         = "ProjectAtlas"
  metric_name       = "disk_used_percent"

  statistic           = "Average"
  period              = 300
  evaluation_periods  = 1
  threshold           = 80
  comparison_operator = "GreaterThanOrEqualToThreshold"

  treat_missing_data = "missing"

  dimensions = {
    InstanceId = aws_instance.project_atlas.id
    path       = "/"
    device     = "nvme0n1p1"
    fstype     = "ext4"
  }

  alarm_actions = [
    aws_sns_topic.project_atlas_alerts.arn
  ]

  ok_actions = [
    aws_sns_topic.project_atlas_alerts.arn
  ]

  tags = {
    Project = "Project Atlas"
  }
}

resource "aws_sns_topic" "project_atlas_alerts" {
  name = "project-atlas-alerts"

  tags = {
    Project = "Project Atlas"
  }
}

resource "aws_sns_topic_subscription" "project_atlas_email" {
  topic_arn = aws_sns_topic.project_atlas_alerts.arn
  protocol  = "email"
  endpoint  = "francis.mallari@icloud.com"
}
