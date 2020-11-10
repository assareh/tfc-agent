import boto3
import hashlib
import hmac
import json
import os

CLUSTER = os.getenv("CLUSTER", None)
DYNAMO_TABLE = os.environ["DYNAMO_TABLE_NAME"]
MAX_AGENTS = os.getenv("MAX_AGENTS", None)
REGION = os.getenv("REGION", None)
SALT_PATH = os.getenv("SALT_PATH", None)
SERVICE = os.getenv("SERVICE", None)

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
dyn = session.client('dynamodb')
table = dyn.Table(DYNAMO_TABLE)


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
            post_response = update_service_count(ecs, int(service_count) + 1)
        elif body['run_status'] in SUB_SERVICE_STATES:
            post_response = update_service_count(ecs, int(service_count) - 1)

    return {
        "statusCode": 200,
        "body": json.dumps(post_response)
    }


def update_service_count(client, desired_count):
    if desired_count < 0:
        desired_count = 0
    elif desired_count > int(MAX_AGENTS):
        # write it in if empty
        # increment by one if not empty
        desired_count = int(MAX_AGENTS)
    else:          
        # either incrememnting 0 to 1, ignore DDB
        # decrementing 1 to 0, ignore DDB
        # or decrementing DDB but keeping desired at max 
        # or clearing DDB 
        
    client.update_service(
        cluster=CLUSTER,
        service=SERVICE,
        desiredCount=desired_count
    )

    print("Updated service count:", desired_count)
    return("Updated service count:", desired_count)


table.put_item(
            Item={
                'id' : str(uuid.uuid4()),
                'timestamp': int(time.time()),
                'payload' : json.dumps(payload)
            }
        )