import hashlib
import hmac
import json
import logging
import requests
import os
import azure.functions as func
from azure.identity import DefaultAzureCredential
# from azure.mgmt.containerinstance import ContainerInstanceManagementClient
# from azure.mgmt.resource import ResourceManagementClient
# switched to REST API because library was causing AD permissions errors


ON_STATES = {'pending', 'policy_checked'}
OFF_STATES = {
    'errored',
    'canceled',
    'discarded',
    'planned_and_finished',
    'applied',
    'completed'
}

def main(req: func.HttpRequest) -> func.HttpResponse:
    message = str(req.get_body())
    payload = json.loads(req.get_body())
    signature = req.headers.get('X-Tfe-Notification-Signature')
    post_response = "I'm here!"

    secret = bytes(os.getenv('SALT', None), 'utf-8')
    hash = hmac.new(secret, req.get_body(), hashlib.sha512)

    if hash.hexdigest() == signature:
        # HMAC verified
        if payload and 'run_status' in payload['notifications'][0]:
            body = payload['notifications'][0]
            print(body['run_status'])
            if body['run_status'] in ON_STATES:
                print(body['run_status'], "Run status indicates turn on the agent.")
                post_response = update_service('on')
            elif body['run_status'] in OFF_STATES:
                print(body['run_status'], "Run status indicates turn off the agent.")
                post_response = update_service('off')

        return func.HttpResponse(
                json.dumps(post_response),
                headers={"Content-Type": "application/json",
                         "Access-Control-Allow-Origin": "*"
                         },
                status_code=200
        )

    return 'Invalid HMAC'


def update_service(operation):
    default_credential = DefaultAzureCredential()
    access_token = default_credential.get_token(
                   'https://management.azure.com/')

    subscription_id = os.getenv('AZURE_SUBSCRIPTION_ID', None)
    resource_group = os.getenv('RESOURCE_GROUP', None)
    container_group = os.getenv('CONTAINER_GROUP', None)

    # Craft start/stop request payloads
    headers = {'Authorization': 'Bearer ' + access_token.token,
               'Content-Type': 'application/json'}
    start_url = "https://management.azure.com/subscriptions/" + \
                subscription_id + \
                "/resourceGroups/" + \
                resource_group + \
                "/providers/Microsoft.ContainerInstance/containerGroups/" + \
                container_group + \
                "/start?api-version=2019-12-01"
    stop_url = "https://management.azure.com/subscriptions/" + \
               subscription_id + \
               "/resourceGroups/" + \
               resource_group + \
               "/providers/Microsoft.ContainerInstance/containerGroups/" + \
               container_group + \
               "/stop?api-version=2019-12-01"

    # resource_client = ResourceManagementClient(
    #     credential=default_credential,
    #     subscription_id=subscription_id
    # )
    # containerinstance_client = ContainerInstanceManagementClient(
    #     credential=default_credential,
    #     subscription_id=subscription_id
    # )
    # container_group = containerinstance_client.container_groups.get(
    #     resource_group,
    #     container_group
    # )
    # print("Get container group:\n{}".format(container_group))

    if operation == 'on':
        r = requests.post(url=start_url, headers=headers)
        print(r.text)
        # containerinstance_client.container_groups.begin_start(
        #     resource_group,
        #     container_group
        # )

    elif operation == 'off':
        r = requests.post(url=stop_url, headers=headers)
        print(r.text)
        # containerinstance_client.container_groups.stop(
        #     resource_group,
        #     container_group
        # )

    else:
        return

    print("Updated service status:", operation)
    return("Updated service status:", operation)
