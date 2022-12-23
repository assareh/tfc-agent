"""A webhook receiver for starting/stopping tfc-agents"""

import hashlib
import hmac
import json
import os
import boto3
import requests


CLUSTER = os.getenv("CLUSTER", None)
MAX_AGENTS = os.getenv("MAX_AGENTS", None)
REGION = os.getenv("REGION", None)
SALT_PATH = os.getenv("SALT_PATH", None)
SERVICE = os.getenv("SERVICE", None)
SSM_PARAM_NAME = os.getenv("SSM_PARAM_NAME", None)


SUB_SERVICE_STATES = {
    'applied',
    'canceled',
    'errored'
}

# Initialize boto3 client at global scope for connection reuse
session = boto3.Session(region_name=REGION)
ssm = session.client('ssm')
ecs = session.client('ecs')


def lambda_handler(event, _context):
    """Primary handler for incoming requests"""
    print(event)
    message = bytes(event['body'], 'utf-8')
    secret = bytes(ssm.get_parameter(Name=SALT_PATH, WithDecryption=True)[
                   'Parameter']['Value'], 'utf-8')
    calculated_hash = hmac.new(secret, message, hashlib.sha512)
    headers = {k.lower(): v for k, v in event['headers'].items()}

    if 'x-tfe-notification-signature' in headers: # notification
        if calculated_hash.hexdigest() == headers['x-tfe-notification-signature']:
            # Notification HMAC verified
            if 'requestContext' in event:
                if 'http' in event['requestContext']:
                    if event['requestContext']['http']['method'] == "POST":
                        return post(event)
                if 'httpMethod' in event['requestContext']:
                    if event['requestContext']['httpMethod'] == "POST":
                        return post(event)
            return get()
        return 'Invalid HMAC'

    if 'x-tfc-task-signature' in headers: # run task
        if calculated_hash.hexdigest() == headers['x-tfc-task-signature']:
            # Run Task HMAC verified
            if 'requestContext' in event:
                if 'http' in event['requestContext']:
                    if event['requestContext']['http']['method'] == "POST":
                        return post(event)
                if 'httpMethod' in event['requestContext']:
                    if event['requestContext']['httpMethod'] == "POST":
                        return post(event)
            return get()
        return 'Invalid HMAC'

    return None


def get():
    """Handler for GET requests"""
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": "I'm here!"
    }


def post(event):
    """Handler for POST requests"""
    payload = json.loads(event['body'])
    post_response = "I'm here!"

    ecs_response = ecs.describe_services(
        cluster=CLUSTER,
        services=[
            SERVICE,
        ]
    )

    service_count = ecs_response['services'][0]['desiredCount']
    print(f"Current service count: {int(service_count)}")

    if 'task_result_callback_url' in payload:  # it's a run task
        if payload['task_result_enforcement_level'] == 'test':
            return {
                "statusCode": 200,
                "body": json.dumps(post_response)
            }

        if payload['stage'] == 'pre_apply' or payload['stage'] == 'pre_plan':
            post_response = update_service_count(ecs, 'add')
            print(f"Run task indicates add an agent for {payload['run_id']}.")
            print(f"{payload['run_app_url']}")

            tfc_headers = {'Authorization': 'Bearer ' + payload['access_token'],
                            'Content-Type': 'application/vnd.api+json'}
            tfc_body = {"data": {"type": "task-results",
                                    "attributes": {"status": "passed",
                                                "message": "tfc-agent autosleeper"}}}
            callback_response = requests.patch(
                payload['task_result_callback_url'], headers=tfc_headers, json=tfc_body)
            print('Callback response from TFC:', callback_response.status_code,
                    callback_response.text)

        if payload['stage'] == 'post_plan':
            post_response = update_service_count(ecs, 'sub')
            print(f"Run task indicates subtract an agent for {payload['run_id']}.")
            print(f"{payload['run_app_url']}")

            tfc_headers = {'Authorization': 'Bearer ' + payload['access_token'],
                            'Content-Type': 'application/vnd.api+json'}
            tfc_body = {"data": {"type": "task-results",
                                    "attributes": {"status": "passed",
                                                "message": "tfc-agent autosleeper"}}}
            callback_response = requests.patch(
                payload['task_result_callback_url'], headers=tfc_headers, json=tfc_body)
            print('Callback response:', callback_response.status_code,
                    callback_response.text)

    else:  # it's a workspace notification
        if payload and 'run_status' in payload['notifications'][0]:
            body = payload['notifications'][0]
            if body['run_status'] in SUB_SERVICE_STATES:
                post_response = update_service_count(ecs, 'sub')
                print(f"Run status indicates subtract an agent for {payload['run_id']}.")
                print(f"{payload['run_url']}")

    return {
        "statusCode": 200,
        "body": json.dumps(post_response)
    }


def update_service_count(client, operation):
    """Increase or decrease number of agents"""
    num_runs_queued = int(ssm.get_parameter(
        Name=SSM_PARAM_NAME)['Parameter']['Value'])
    if operation == 'add':
        num_runs_queued = num_runs_queued + 1
    elif operation == 'sub':
        num_runs_queued = num_runs_queued - 1 if num_runs_queued > 0 else 0
    else:
        return None

    ssm.put_parameter(Name=SSM_PARAM_NAME, Value=str(
        num_runs_queued), Type='String', Overwrite=True)

    desired_count = int(MAX_AGENTS) if num_runs_queued > int(
        MAX_AGENTS) else num_runs_queued
    client.update_service(
        cluster=CLUSTER,
        service=SERVICE,
        desiredCount=desired_count
    )

    print(f"Updated service count: {desired_count}")
    return ("Updated service count:", desired_count)
