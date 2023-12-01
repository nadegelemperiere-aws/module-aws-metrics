# -------------------------------------------------------
# Copyright (c) [2021] Nadege Lemperiere
# All rights reserved
# -------------------------------------------------------
# Module to deploy the metrics and alarms associated to
# an AWS infrastructure
# -------------------------------------------------------
# Nadège LEMPERIERE, @14 november 2021
# Latest revision: 14 november 2021
# -------------------------------------------------------

# -------------------------------------------------------
# Configure a filter to create metric from log
# -------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "metric" {

	count = length(var.logs_to_metrics)

	name           = var.logs_to_metrics[count.index].name
	pattern        = var.logs_to_metrics[count.index].filter
	log_group_name = var.cloudwatch.name

	metric_transformation {
		name 		= var.logs_to_metrics[count.index].name
		namespace 	= var.logs_to_metrics[count.index].namespace
		value 		= var.logs_to_metrics[count.index].value
		unit		= var.logs_to_metrics[count.index].unit
		dimensions  = var.logs_to_metrics[count.index].dimensions
  	}
}

# -------------------------------------------------------
# Configure an alarm from metric
# -------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "alarm" {

	count = length(var.metrics_to_alarms)

  	alarm_name          = var.metrics_to_alarms[count.index].metric
  	comparison_operator = var.metrics_to_alarms[count.index].operator
  	evaluation_periods  = var.metrics_to_alarms[count.index].evaluation
  	metric_name         = var.metrics_to_alarms[count.index].metric
  	namespace           = var.metrics_to_alarms[count.index].namespace
  	period              = var.metrics_to_alarms[count.index].period
  	statistic           = var.metrics_to_alarms[count.index].statistic
  	threshold           = var.metrics_to_alarms[count.index].threshold
  	alarm_description   = var.metrics_to_alarms[count.index].description
	alarm_actions		= length(var.emails) != 0 ? [aws_sns_topic.alarm[0].arn] : []

    tags = {
		Name           	= "${var.project}.${var.environment}.${var.module}.${var.name}.alarm.${count.index}"
		Environment     = var.environment
		Owner   		= var.email
		Project   		= var.project
		Version 		= var.git_version
		Module  		= var.module
	}
}

# -------------------------------------------------------
# Configure action on alarm
# -------------------------------------------------------
resource "aws_sns_topic" "alarm" {

	count 	= length(var.emails) != 0 ? 1 : 0

  	name              = "${var.project}-${var.name}-alarm"
  	kms_master_key_id = aws_kms_key.key[0].id
  	delivery_policy   = jsonencode({

		http = {
			defaultHealthyRetryPolicy = {
				minDelayTarget 		= 20
      			maxDelayTarget 		= 20
      			numRetries 			= 3
      			numMaxDelayRetries 	= 0
      			numNoDelayRetries 	= 0
      			numMinDelayRetries 	= 0,
      			backoffFunction 	= "linear"
			}
			disableSubscriptionOverrides = false
			defaultThrottlePolicy = {
				maxReceivesPerSecond = 1
			}
		}
  	})

	application_success_feedback_role_arn 	= var.cloudwatch.role
	application_failure_feedback_role_arn 	= var.cloudwatch.role
	http_success_feedback_role_arn 			= var.cloudwatch.role
	http_failure_feedback_role_arn 			= var.cloudwatch.role
	lambda_success_feedback_role_arn 		= var.cloudwatch.role
	lambda_failure_feedback_role_arn		= var.cloudwatch.role
	sqs_success_feedback_role_arn 			= var.cloudwatch.role
	sqs_failure_feedback_role_arn 			= var.cloudwatch.role
	firehose_success_feedback_role_arn 		= var.cloudwatch.role
	firehose_failure_feedback_role_arn 		= var.cloudwatch.role

	tags = {
		Name           	= "${var.project}.${var.environment}.${var.module}.${var.name}.alarm"
		Environment     = var.environment
		Owner   		= var.email
		Project   		= var.project
		Version 		= var.git_version
		Module  		= var.module
	}
}

# -------------------------------------------------------
# Gives notification right to cloudwatch
# -------------------------------------------------------
resource "aws_sns_topic_policy" "alarm" {

	count 	= length(var.emails) != 0 ? 1 : 0

  	arn 	= aws_sns_topic.alarm[0].arn
	policy 	= jsonencode({
  		Version = "2012-10-17",
  		Statement = [
    		{
      			Principal 	=  {
					"Service": [ "cloudwatch.amazonaws.com" ]
				}
      			Effect 	    = "Allow"
      			Action      = ["sns:Publish"]
      			Resource    = aws_sns_topic.alarm[0].arn
    		}
  		]
	})
}

# -------------------------------------------------------
# Subscribe email to alarm
# -------------------------------------------------------
resource "aws_sns_topic_subscription" "alarm" {

	count 		= length(var.emails)
  	topic_arn 	= aws_sns_topic.alarm[0].arn
  	protocol  	= "email"
  	endpoint  	= var.emails[count.index]
}

# -------------------------------------------------------
# Cloudtrail encryption key
# -------------------------------------------------------
resource "aws_kms_key" "key" {

  	count 	= length(var.emails) != 0 ? 1 : 0

	description             	= "Alarm email encryption key"
	key_usage					= "ENCRYPT_DECRYPT"
	customer_master_key_spec	= "SYMMETRIC_DEFAULT"
	deletion_window_in_days		= 7
	enable_key_rotation			= true
  	policy						= jsonencode({
  		Version = "2012-10-17",
  		Statement = [
			{
				Sid 			= "AllowKeyModificationToRootAndGod"
				Effect			= "Allow"
				Principal		= {
					"AWS" : [
						"arn:aws:iam::${var.account}:root",
						"arn:aws:iam::${var.account}:user/${var.service_principal}"
					]
				}
				Action 			= [ "kms:*" ]
                Resource		= "*"
       		},
			{
				Sid 		= "AllowKeyDescriptionToCloudwatchAndSns"
      			Effect 		= "Allow"
				Principal 	= {
					"Service" : [ "sns.amazonaws.com", "cloudwatch.amazonaws.com" ]
				}
      			Action  	= [ "kms:DescribeKey"]
                Resource	= "*"
    		},
			{
      			Sid 		= "AllowKeyGenerationToCloudwatchAndSns"
      			Effect 		= "Allow"
				Principal 	= {
					"Service" : [ "sns.amazonaws.com", "cloudwatch.amazonaws.com" ]
				}
      			Action  	= [ "kms:GenerateDataKey*"]
                Resource	= "*"
    		},
			{
      			Sid 		= "AllowDecryptionToCloudwatchAndSns"
      			Effect 		= "Allow"
				Principal 	= {
					"Service" : [ "sns.amazonaws.com", "cloudwatch.amazonaws.com" ]
				}
      			Action  	= [ "kms:Decrypt"]
                Resource	= "*"
    		}
  		]
	})

	tags = {
		Name           	= "${var.project}.${var.environment}.${var.module}.${var.name}.alarm"
		Environment     = var.environment
		Owner   		= var.email
		Project   		= var.project
		Version 		= var.git_version
		Module  		= var.module
	}
}