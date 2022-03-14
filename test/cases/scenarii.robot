# -------------------------------------------------------
# TECHNOGIX
# -------------------------------------------------------
# Copyright (c) [2021] Technogix.io
# All rights reserved
# -------------------------------------------------------
# Robotframework test suite for module
# -------------------------------------------------------
# Nadège LEMPERIERE, @12 november 2021
# Latest revision: 12 november 2021
# -------------------------------------------------------


*** Settings ***
Documentation   A test case to check metrics creation
Library         technogix_iac_keywords.terraform
Library         technogix_iac_keywords.keepass
Library         technogix_iac_keywords.cloudwatch
Library         technogix_iac_keywords.sns
Library         ../keywords/data.py

*** Variables ***
${KEEPASS_DATABASE}                 ${vault_database}
${KEEPASS_KEY}                      ${vault_key}
${KEEPASS_GOD_KEY_ENTRY}            /engineering-environment/aws/aws-god-access-key
${KEEPASS_GOD_USER_ENTRY}           /engineering-environment/aws/aws-god-credentials
${KEEPASS_ACCOUNT_ENTRY}            /engineering-environment/aws/aws-account
${REGION}                           eu-west-1

*** Test Cases ***
Prepare environment
    [Documentation]         Retrieve god credential from database and initialize python tests keywords
    ${god_access}           Load Keepass Database Secret            ${KEEPASS_DATABASE}     ${KEEPASS_KEY}  ${KEEPASS_GOD_KEY_ENTRY}            username
    ${god_secret}           Load Keepass Database Secret            ${KEEPASS_DATABASE}     ${KEEPASS_KEY}  ${KEEPASS_GOD_KEY_ENTRY}            password
    ${god_name}             Load Keepass Database Secret            ${KEEPASS_DATABASE}     ${KEEPASS_KEY}  ${KEEPASS_GOD_USER_ENTRY}           username
    ${ACCOUNT}              Load Keepass Database Secret            ${KEEPASS_DATABASE}     ${KEEPASS_KEY}  ${KEEPASS_ACCOUNT_ENTRY}            password
    ${TF_PARAMETERS}=       Create Dictionary   account="${ACCOUNT}"    service_principal="${god_name}"
    Initialize Terraform    ${REGION}   ${god_access}   ${god_secret}
    Initialize Cloudwatch   None        ${god_access}   ${god_secret}    ${REGION}
    Initialize SNS          None        ${god_access}   ${god_secret}    ${REGION}
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
