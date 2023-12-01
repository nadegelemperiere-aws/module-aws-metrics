# -------------------------------------------------------
# Copyright (c) [2021] Naege Lemperiere
# All rights reserved
# -------------------------------------------------------
# Keywords to create data for module test
# -------------------------------------------------------
# Nadège LEMPERIERE, @13 november 2021
# Latest revision: 13 november 2021
# -------------------------------------------------------

# System includes
from json import load, dumps
from typing import ContextManager

# Robotframework includes
from robot.libraries.BuiltIn import BuiltIn, _Misc
from robot.api import logger as logger
from robot.api.deco import keyword
ROBOT = False

# ip address manipulation
from ipaddress import IPv4Network

@keyword('Load Metrics Test Data')
def load_metrics_test_data(loggroup, metrics, alarms, notifications, key) :

    if len(alarms['arn']) != 0 : raise Exception(str(len(alarms['arn'])) + ' alarms created instead of 0')
    if len(metrics['id']) != 1 : raise Exception(str(len(metrics['id'])) + ' metrics created instead of 1')
    if len(notifications['id']) != 0 : raise Exception(str(len(notifications['id'])) + ' notifications created instead of 0')
    if len(notifications['subscriptions']) != 0 : raise Exception(str(len(notifications['subscriptions'])) + ' subscriptions created instead of 0')
    if len(key['id']) != 0 : raise Exception(str(len(key['id'])) + ' keys created instead of 0')

    result = {}
    result['metrics'] = []

    result['metrics'].append({})
    result['metrics'][0]['name'] = 'metric'
    result['metrics'][0]['data'] = {}
    result['metrics'][0]['data']['filterName'] = 'test'
    result['metrics'][0]['data']['filterPattern'] = '{ $.userIdentity.type = \"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != \"AwsServiceEvent\" }'
    result['metrics'][0]['data']['metricTransformations'] =  [
        {'metricName': 'test', 'metricNamespace': 'test', 'metricValue': '1', 'unit': 'Count'}
    ]
    result['metrics'][0]['data']['logGroupName'] = loggroup['name']

    logger.debug(dumps(result))

    return result

@keyword('Load Alarms Test Data')
def load_alarms_test_data(loggroup, metrics, alarms, notifications, key) :

    if len(alarms['arn']) != 1 : raise Exception(str(len(alarms['arn'])) + ' alarms created instead of 1')
    if len(metrics['id']) != 1 : raise Exception(str(len(metrics['id'])) + ' metrics created instead of 1')
    if len(notifications['id']) != 0 : raise Exception(str(len(notifications['id'])) + ' notifications created instead of 0')
    if len(notifications['subscriptions']) != 0 : raise Exception(str(len(notifications['subscriptions'])) + ' subscriptions created instead of 0')
    if len(key['id']) != 0 : raise Exception(str(len(key['id'])) + ' keys created instead of 0')

    result = {}
    result['metrics'] = []
    result['alarms'] = []

    result['metrics'].append({})
    result['metrics'][0]['name'] = 'metric'
    result['metrics'][0]['data'] = {}
    result['metrics'][0]['data']['filterName'] = 'test'
    result['metrics'][0]['data']['filterPattern'] = '{ $.userIdentity.type = \"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != \"AwsServiceEvent\" }'
    result['metrics'][0]['data']['metricTransformations'] =  [
        {'metricName': 'test', 'metricNamespace': 'test', 'metricValue': '1', 'unit': 'Count'}
    ]
    result['metrics'][0]['data']['logGroupName'] = loggroup['name']

    result['alarms'].append({})
    result['alarms'][0]['name'] = 'alarm'
    result['alarms'][0]['data'] = {}
    result['alarms'][0]['data']['AlarmName'] = 'test'
    result['alarms'][0]['data']['AlarmArn'] = alarms['arn'][0]
    result['alarms'][0]['data']['AlarmDescription'] = 'This alarm monitors root account usage'
    result['alarms'][0]['data']['ActionsEnabled'] = True
    result['alarms'][0]['data']['MetricName'] = 'test'
    result['alarms'][0]['data']['Namespace'] = 'test'
    result['alarms'][0]['data']['Statistic'] = 'Sum'
    result['alarms'][0]['data']['Dimensions'] = []
    result['alarms'][0]['data']['Period'] = 300
    result['alarms'][0]['data']['EvaluationPeriods'] = 1
    result['alarms'][0]['data']['Threshold'] = 1.0
    result['alarms'][0]['data']['ComparisonOperator'] = 'GreaterThanOrEqualToThreshold'

    logger.debug(dumps(result))

    return result

@keyword('Load Notifications Test Data')
def load_notifications_test_data(loggroup, metrics, alarms, notifications, key, account) :

    if len(alarms['arn']) != 1 : raise Exception(str(len(alarms['arn'])) + ' alarms created instead of 1')
    if len(metrics['id']) != 1 : raise Exception(str(len(metrics['id'])) + ' metrics created instead of 1')
    if len(notifications['id']) != 1 : raise Exception(str(len(notifications['id'])) + ' notifications created instead of 1')
    if len(notifications['subscriptions']) != 1 : raise Exception(str(len(notifications['subscriptions'])) + ' subscriptions created instead of 1')
    if len(key['id']) != 1 : raise Exception(str(len(key['id'])) + ' keys created instead of 1')


    result = {}
    result['metrics'] = []
    result['alarms'] = []
    result['subscriptions'] = []
    result['topics'] = []

    result['metrics'].append({})
    result['metrics'][0]['name'] = 'metric'
    result['metrics'][0]['data'] = {}
    result['metrics'][0]['data']['filterName'] = 'test'
    result['metrics'][0]['data']['filterPattern'] = '{ $.userIdentity.type = \"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != \"AwsServiceEvent\" }'
    result['metrics'][0]['data']['metricTransformations'] =  [
        {'metricName': 'test', 'metricNamespace': 'test', 'metricValue': '1', 'unit': 'Count'}
    ]
    result['metrics'][0]['data']['logGroupName'] = loggroup['name']

    result['alarms'].append({})
    result['alarms'][0]['name'] = 'alarm'
    result['alarms'][0]['data'] = {}
    result['alarms'][0]['data']['AlarmName'] = 'test'
    result['alarms'][0]['data']['AlarmArn'] = alarms['arn'][0]
    result['alarms'][0]['data']['AlarmDescription'] = 'This alarm monitors root account usage'
    result['alarms'][0]['data']['ActionsEnabled'] = True
    result['alarms'][0]['data']['MetricName'] = 'test'
    result['alarms'][0]['data']['Namespace'] = 'test'
    result['alarms'][0]['data']['Statistic'] = 'Sum'
    result['alarms'][0]['data']['Dimensions'] = []
    result['alarms'][0]['data']['Period'] = 300
    result['alarms'][0]['data']['EvaluationPeriods'] = 1
    result['alarms'][0]['data']['Threshold'] = 1.0
    result['alarms'][0]['data']['ComparisonOperator'] = 'GreaterThanOrEqualToThreshold'

    for index, subscription in enumerate(notifications['subscriptions']) :
        content = {}
        content['name'] = 'subscription-' + str(index)
        content['data'] = {}
        content['data']['SubscriptionArn'] = 'PendingConfirmation'
        content['data']['Endpoint'] = 'moi@moi.fr'
        content['data']['Protocol'] = 'email'
        content['data']['TopicArn'] = notifications['arn'][0]
        content['data']['Owner'] = account
        result['subscriptions'].append(content)

    result['topics'].append({})
    result['topics'][0]['name'] = 'topic'
    result['topics'][0]['data'] = {}
    result['topics'][0]['data']['TopicArn'] = notifications['arn'][0]
    result['topics'][0]['data']['Attributes'] = {}
    result['topics'][0]['data']['Attributes']['Policy'] = {'Version': '2012-10-17', 'Statement': [{'Effect': 'Allow', 'Principal': {'Service': 'cloudwatch.amazonaws.com'}, 'Action': 'sns:Publish', 'Resource': 'arn:aws:sns:eu-west-1:833168553325:test-test-alarm'}]}
    result['topics'][0]['data']['Attributes']['LambdaSuccessFeedbackRoleArn'] = loggroup['role']
    result['topics'][0]['data']['Attributes']['LambdaFailureFeedbackRoleArn'] = loggroup['role']
    result['topics'][0]['data']['Attributes']['FirehoseFailureFeedbackRoleArn'] = loggroup['role']
    result['topics'][0]['data']['Attributes']['FirehoseSuccessFeedbackRoleArn'] = loggroup['role']
    result['topics'][0]['data']['Attributes']['HTTPFailureFeedbackRoleArn'] = loggroup['role']
    result['topics'][0]['data']['Attributes']['HTTPSuccessFeedbackRoleArn'] = loggroup['role']
    result['topics'][0]['data']['Attributes']['SQSSuccessFeedbackRoleArn'] = loggroup['role']
    result['topics'][0]['data']['Attributes']['SQSFailureFeedbackRoleArn'] = loggroup['role']
    result['topics'][0]['data']['Attributes']['ApplicationFailureFeedbackRoleArn'] = loggroup['role']
    result['topics'][0]['data']['Attributes']['ApplicationSuccessFeedbackRoleArn'] = loggroup['role']
    result['topics'][0]['data']['Attributes']['Owner'] = account
    # result['topics'][0]['data']['Attributes']['SubscriptionsPending'] = '1' : This status only change after a few seconds, preventing the test to happen
    result['topics'][0]['data']['Attributes']['KmsMasterKeyId'] = key['id'][0]
    result['topics'][0]['data']['Attributes']['TopicArn'] = notifications['arn'][0]
    result['topics'][0]['data']['Attributes']['EffectiveDeliveryPolicy'] = {
        'http' : {
            'defaultHealthyRetryPolicy' : {
                'minDelayTarget' : 20,
                'maxDelayTarget' : 20,
                'numRetries' : 3,
                'numMaxDelayRetries' : 0,
                'numNoDelayRetries' : 0,
                'numMinDelayRetries' : 0,
                'backoffFunction' : 'linear'
            },
            'disableSubscriptionOverrides' : False,
            'defaultThrottlePolicy'     : {
                'maxReceivesPerSecond' : 1
            }
        }
    }
    result['topics'][0]['data']['Attributes']['DeliveryPolicy'] = {
        'http' : {
            'defaultHealthyRetryPolicy' : {
                'minDelayTarget' : 20,
                'maxDelayTarget' : 20,
                'numRetries' : 3,
                'numMaxDelayRetries' : 0,
                'numNoDelayRetries' : 0,
                'numMinDelayRetries' : 0,
                'backoffFunction' : 'linear'
            },
            'disableSubscriptionOverrides' : False,
            'defaultThrottlePolicy'     : {
                'maxReceivesPerSecond' : 1
            }
        }
    }

    logger.debug(dumps(result))

    return result