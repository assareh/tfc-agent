import boto3
import hashlib
import hmac
import json
import os


CLUSTER = os.getenv("CLUSTER", None)
MAX_AGENTS = os.getenv("MAX_AGENTS", None)
REGION = os.getenv("REGION", None)
SALT_PATH = os.getenv("SALT_PATH", None)
SERVICE = os.getenv("SERVICE", None)
SSM_PARAM_NAME = os.getenv("SSM_PARAM_NAME", None)


ADD_SERVICE_STATES = {'pending'}
SUB_SERVICE_STATES = {
    'errored',
    'canceled',
    'discarded',
    'planned_and_finished',
    'applied',
    'completed'
}


# Initialize boto3 client at global scope for connection reuse
session = boto3.Session(region_name=REGION)
ssm = session.client('ssm')
ecs = session.client('ecs')


def lambda_handler(event, context):
    print(event)
    message = bytes(event['body'], 'utf-8')
    secret = bytes(ssm.get_parameter(Name=SALT_PATH, WithDecryption=True)['Parameter']['Value'], 'utf-8')
    hash = hmac.new(secret, message, hashlib.sha512)
    if hash.hexdigest() == event['headers']['X-Tfe-Notification-Signature']:
        # HMAC verified
        if event['httpMethod'] == "POST":
            return post(event)
        return get()
    return 'Invalid HMAC'


def get():
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": "I'm here!"
        }


def post(event):
    payload = json.loads(event['body'])
    post_response = "I'm here!"

    response = ecs.describe_services(
        cluster=CLUSTER,
        services=[
            SERVICE,
        ]
    )

    service_count = response['services'][0]['desiredCount']
    print("Current service count:", int(service_count))

    if payload and 'run_status' in payload['notifications'][0]:
        body = payload['notifications'][0]
        if body['run_status'] in ADD_SERVICE_STATES:
            post_response = update_service_count(ecs, 'add')
            print("Run status indicates add an agent.")
        elif body['run_status'] in SUB_SERVICE_STATES:
            post_response = update_service_count(ecs, 'sub')
            print("Run status indicates subtract an agent.")

    return {
        "statusCode": 200,
        "body": json.dumps(post_response)
    }


def update_service_count(client, operation):
    num_runs_queued = int(ssm.get_parameter(Name=SSM_PARAM_NAME)['Parameter']['Value'])
    if operation is 'add':
        num_runs_queued = num_runs_queued + 1
    elif operation is 'sub':
        num_runs_queued=num_runs_queued - 1 if num_runs_queued > 0 else 0
    else:
        return
    response = ssm.put_parameter(Name=SSM_PARAM_NAME, Value=str(num_runs_queued), Type='String', Overwrite=True)

    desired_count=int(MAX_AGENTS) if num_runs_queued > int(MAX_AGENTS) else num_runs_queued
    client.update_service(
        cluster=CLUSTER,
        service=SERVICE,
        desiredCount=desired_count
    )

    print("Updated service count:", desired_count)
    return("Updated service count:", desired_count)
