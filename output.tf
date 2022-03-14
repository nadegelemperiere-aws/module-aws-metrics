# -------------------------------------------------------
# TECHNOGIX
# -------------------------------------------------------
# Copyright (c) [2021] Technogix.io
# All rights reserved
# -------------------------------------------------------
# Module to deploy the metrics and alarms associated to
# an AWS infrastructure
# -------------------------------------------------------
# Nadège LEMPERIERE, @14 november 2021
# Latest revision: 14 november 2021
# -------------------------------------------------------

output "metrics" {
    value = {
        id   = aws_cloudwatch_log_metric_filter.metric.*.id
    }
}

output "alarms" {
    value = {
        arn   = aws_cloudwatch_metric_alarm.alarm.*.arn
        name  = aws_cloudwatch_metric_alarm.alarm.*.metric_name
        namespace = aws_cloudwatch_metric_alarm.alarm.*.namespace
    }
}

output "notifications" {
    value = {
        id              = aws_sns_topic.alarm.*.id
        arn             = aws_sns_topic.alarm.*.arn
        subscriptions   = aws_sns_topic_subscription.alarm.*.id
    }
}

output "key" {
    value = {
        arn     = aws_kms_key.key.*.arn
        id      = aws_kms_key.key.*.id
    }
}
