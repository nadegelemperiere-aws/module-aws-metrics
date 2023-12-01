# -------------------------------------------------------
# Copyright (c) [2021] Nadege Lemperiere
# All rights reserved
# -------------------------------------------------------
# Robotframework test suite for module
# -------------------------------------------------------
# Nadège LEMPERIERE, @12 november 2021
# Latest revision: 12 november 2021
# -------------------------------------------------------


*** Settings ***
Documentation   A test case to check metrics creation
Library         aws_iac_keywords.terraform
Library         aws_iac_keywords.keepass
Library         aws_iac_keywords.cloudwatch
Library         aws_iac_keywords.sns
Library         ../keywords/data.py
Library         OperatingSystem

*** Variables ***
${KEEPASS_DATABASE}                 ${vault_database}
${KEEPASS_KEY_ENV}                  ${vault_key_env}
${KEEPASS_PRINCIPAL_KEY_ENTRY}      /aws/aws-principal-access-key
${KEEPASS_PRINCIPAL_USER_ENTRY}     /aws/aws-principal-credentials
${KEEPASS_ACCOUNT_ENTRY}            /aws/aws-account
${REGION}                           eu-west-1

*** Test Cases ***
Prepare environment
    [Documentation]         Retrieve principal credential from database and initialize python tests keywords
    ${keepass_key}          Get Environment Variable          ${KEEPASS_KEY_ENV}
    ${principal_access}     Load Keepass Database Secret      ${KEEPASS_DATABASE}     ${keepass_key}  ${KEEPASS_PRINCIPAL_KEY_ENTRY}            username
    ${principal_secret}     Load Keepass Database Secret      ${KEEPASS_DATABASE}     ${keepass_key}  ${KEEPASS_PRINCIPAL_KEY_ENTRY}            password
    ${principal_name}       Load Keepass Database Secret      ${KEEPASS_DATABASE}     ${keepass_key}  ${KEEPASS_PRINCIPAL_USER_ENTRY}           username
    ${ACCOUNT}              Load Keepass Database Secret      ${KEEPASS_DATABASE}     ${keepass_key}  ${KEEPASS_ACCOUNT_ENTRY}            password
    ${TF_PARAMETERS}=       Create Dictionary   account="${ACCOUNT}"    service_principal="${principal_name}"
    Initialize Terraform    ${REGION}   ${principal_access}   ${principal_secret}
    Initialize Cloudwatch   None        ${principal_access}   ${principal_secret}    ${REGION}
    Initialize SNS          None        ${principal_access}   ${principal_secret}    ${REGION}
    Set Global Variable     ${TF_PARAMETERS}
    Set Global Variable     ${ACCOUNT}

Create Metrics
    [Documentation]         Create Metrics
    Launch Terraform Deployment                 ${CURDIR}/../data/metrics     ${TF_PARAMETERS}
    ${states}   Load Terraform States           ${CURDIR}/../data/metrics
    ${specs}    Load Metrics Test Data          ${states['test']['outputs']['loggroup']['value']}    ${states['test']['outputs']['metrics']['value']}    ${states['test']['outputs']['alarms']['value']}     ${states['test']['outputs']['notifications']['value']}  ${states['test']['outputs']['key']['value']}
    Metrics Shall Exist And Match               ${specs['metrics']}
    [Teardown]  Destroy Terraform Deployment    ${CURDIR}/../data/metrics     ${TF_PARAMETERS}

Create Alarms
    [Documentation]         Create Metrics and Alarms
    Launch Terraform Deployment                 ${CURDIR}/../data/alarms     ${TF_PARAMETERS}
    ${states}   Load Terraform States           ${CURDIR}/../data/alarms
    ${specs}    Load Alarms Test Data    ${states['test']['outputs']['loggroup']['value']}    ${states['test']['outputs']['metrics']['value']}    ${states['test']['outputs']['alarms']['value']}     ${states['test']['outputs']['notifications']['value']}  ${states['test']['outputs']['key']['value']}
    Metrics Shall Exist And Match               ${specs['metrics']}
    Alarms Shall Exist And Match                ${specs['alarms']}
    [Teardown]  Destroy Terraform Deployment    ${CURDIR}/../data/alarms     ${TF_PARAMETERS}

Create Notifications
    [Documentation]         Create Metrics, Alarms and Notification
    Launch Terraform Deployment                 ${CURDIR}/../data/notifications     ${TF_PARAMETERS}
    ${states}   Load Terraform States           ${CURDIR}/../data/notifications
    ${specs}    Load Notifications Test Data    ${states['test']['outputs']['loggroup']['value']}    ${states['test']['outputs']['metrics']['value']}    ${states['test']['outputs']['alarms']['value']}     ${states['test']['outputs']['notifications']['value']}  ${states['test']['outputs']['key']['value']}   ${ACCOUNT}
    Metrics Shall Exist And Match               ${specs['metrics']}
    Alarms Shall Exist And Match                ${specs['alarms']}
    Subscriptions Shall Exist And Match         ${specs['subscriptions']}
    Topics Shall Exist And Match                ${specs['topics']}
    [Teardown]  Destroy Terraform Deployment    ${CURDIR}/../data/notifications     ${TF_PARAMETERS}
