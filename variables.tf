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

# -------------------------------------------------------
# Contact e-mail for this deployment
# -------------------------------------------------------
variable "email" {
	type 	= string
}

# -------------------------------------------------------
# Environment for this deployment (prod, preprod, ...)
# -------------------------------------------------------
variable "environment" {
	type 	= string
}

# -------------------------------------------------------
# Topic context for this deployment
# -------------------------------------------------------
variable "project" {
	type    = string
}
variable "module" {
	type 	= string
}
variable "name" {
	type = string
}

# -------------------------------------------------------
# Solution version
# -------------------------------------------------------
variable "git_version" {
	type    = string
	default = "unmanaged"
}

# -------------------------------------------------------
# AWS account in which the permission shall be given
# -------------------------------------------------------
variable "account" {
	type = string
}
variable "service_principal" {
	type = string
}

# -------------------------------------------------------
# Loggroup name to analyze for metrics
# -------------------------------------------------------
variable "cloudwatch" {
	type = object({
		name 	= string
		role	= string
	})
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
}

# -------------------------------------------------------
# List of email to alert on alarm
# -------------------------------------------------------
variable "emails" {
	type 				= list(string)
	default 			= []
}