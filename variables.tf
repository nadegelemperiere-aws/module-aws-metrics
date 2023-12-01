# -------------------------------------------------------
# Copyright (c) [2021] Nadege Lemperiere
# All rights reserved
# -------------------------------------------------------
# Module to deploy the metrics and alarms associated to
# an AWS infrastructure
# -------------------------------------------------------
# Nadège LEMPERIERE, @14 november 2021
# Latest revision: 30 november 2023
# -------------------------------------------------------

# -------------------------------------------------------
# Contact e-mail for this deployment
# -------------------------------------------------------
variable "email" {
	type 	 = string
	nullable = false
}

# -------------------------------------------------------
# Environment for this deployment (prod, preprod, ...)
# -------------------------------------------------------
variable "environment" {
	type 	 = string
	nullable = false
}

# -------------------------------------------------------
# Topic context for this deployment
# -------------------------------------------------------
variable "project" {
	type     = string
	nullable = false
}
variable "module" {
	type 	 = string
	nullable = false
}
variable "name" {
	type     = string
	nullable = false
}

# -------------------------------------------------------
# Solution version
# -------------------------------------------------------
variable "git_version" {
	type     = string
	default  = "unmanaged"
	nullable = false
}

# -------------------------------------------------------
# AWS account in which the permission shall be given
# -------------------------------------------------------
variable "account" {
	type     = string
	nullable = false
}
variable "service_principal" {
	type     = string
	nullable = false
}

# -------------------------------------------------------
# Loggroup name to analyze for metrics
# -------------------------------------------------------
variable "cloudwatch" {
	type = object({
		name 	= string
		role	= string
	})
	nullable = false
}

# -------------------------------------------------------
# Metric creation from log
# -------------------------------------------------------
variable "logs_to_metrics" {
	type    	= list(object({
        filter			= string,
		namespace		= string,
		name      		= string,
    	value     		= string,
		unit			= string,
		dimensions		= map(string)
    }))
	default 			= []
	nullable            = false
}

# -------------------------------------------------------
# Alarm creation from metric
# -------------------------------------------------------
variable "metrics_to_alarms" {
	type    	= list(object({
        metric			= string,
		evaluation	 	= string,
		operator 		= string,
		namespace		= string,
		period			= string,
		statistic		= string,
		threshold		= string,
		description		= string
    }))
	default 			= []
	nullable            = false
}

# -------------------------------------------------------
# List of email to alert on alarm
# -------------------------------------------------------
variable "emails" {
	type 				= list(string)
	default 			= []
	nullable            = false
}