# -------------------------------------------------------
# Copyright (c) [2021] Nadege Lemperiere
# All rights reserved
# -------------------------------------------------------
# Simple deployment for metrics testing
# -------------------------------------------------------
# Nadège LEMPERIERE, @20 november 2021
# Latest revision: 20 november 2021
# -------------------------------------------------------

# -------------------------------------------------------
# Create the loggroup
# -------------------------------------------------------
resource "random_string" "random" {
	length		= 32
	special		= false
	upper 		= false
}
resource "aws_cloudwatch_log_group" "group" {
  name =  random_string.random.result
}

# -----------------------------------------------------------
# Create role to enable writing in the loggroup
# -----------------------------------------------------------
resource "aws_iam_role" "group" {

  	name = "test"
  	assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
   			{
      			Effect 		= "Allow"
      			Principal 	=  { "Service": "sns.amazonaws.com" }
    			Action 		= "sts:AssumeRole"
    		}
  		]
	})
}
resource "aws_iam_role_policy" "group" {

  	name = "test"
  	role = aws_iam_role.group.id

  	policy = jsonencode({
  		Version = "2012-10-17",
  		Statement = [
    		{
      			Effect 	= "Allow"
      			Action  = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:DescribeLogGroups",  "logs:DescribeLogStreams"]
      			Resource: "${aws_cloudwatch_log_group.group.arn}:*"
    		},
    		{
      			Effect 	= "Allow"
      			Action = ["logs:PutLogEvents"]
      			Resource = "${aws_cloudwatch_log_group.group.arn}:*"
    		}
  		]
	})
}

# -------------------------------------------------------
# Create permissions using the current module
# -------------------------------------------------------
module "metrics" {
    source      		= "../../../"
    email 				= "moi.moi@moi.fr"
	project 			= "test"
	environment 		= "test"
	module 				= "test"
	git_version 		= "test"
	name				= "test"
    account     		= var.account
	service_principal 	= var.service_principal
	cloudwatch			= {
		name 		= aws_cloudwatch_log_group.group.name
		role		= aws_iam_role.group.arn
	}
	logs_to_metrics 	= [
		{
			filter 		= "{ $.userIdentity.type = \"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != \"AwsServiceEvent\" }"
			namespace 	= "test"
			name		= "test"
			value		= "1"
			unit 		= "Count"
			dimensions 	= {}
		}
	]
	metrics_to_alarms	= [
		{
			description	= "This alarm monitors root account usage"
			metric		= "test"
			evaluation	= "1"
			operator	= "GreaterThanOrEqualToThreshold"
			namespace	= "test"
			period		= "300"
			statistic	= "Sum"
			threshold	= "1"
		}
	]
	emails = ["moi@moi.fr"]
}

# -------------------------------------------------------
# Terraform configuration
# -------------------------------------------------------
provider "aws" {
	region		= var.region
	access_key 	= var.access_key
	secret_key	= var.secret_key
}

terraform {
	required_version = ">=1.0.8"
	backend "local"	{
		path="terraform.tfstate"
	}
}

# -------------------------------------------------------
# AWS configuration for this deployment
# -------------------------------------------------------
variable "region" {
	type    = string
}
variable "account" {
	type    = string
}
variable "service_principal" {
	type    = string
}

# -------------------------------------------------------
# AWS credentials
# -------------------------------------------------------
variable "access_key" {
	type    	= string
	sensitive 	= true
}
variable "secret_key" {
	type    	= string
	sensitive 	= true
}

# -------------------------------------------------------
# Outputs
# -------------------------------------------------------
output "loggroup" {
    value = {
        arn     = aws_cloudwatch_log_group.group.arn
        name    = aws_cloudwatch_log_group.group.name
        id      = aws_cloudwatch_log_group.group.id
		role 	= aws_iam_role.group.arn
    }
}

output "metrics" {
    value = module.metrics.metrics
}

output "alarms" {
	value = module.metrics.alarms
}

output "notifications" {
	value = module.metrics.notifications
}

output "key" {
	value = module.metrics.key
}

