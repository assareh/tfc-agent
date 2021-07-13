## TODO
* need to add tags to resources

# README
The credentials you use to provision this workspace will require `roleAssignments/write` permission. For reference, please see this [answer](https://docs.microsoft.com/en-us/answers/questions/287573/authorization-failed-when-when-writing-a-roleassig.html). I created a custom role based on the built-in `Contributor` role with the following steps:

1. Get the role definition:
```
→ az role definition list -n "Contributor"
[
  {
    "assignableScopes": [
      "/"
    ],
    "description": "Grants full access to manage all resources, but does not allow you to assign roles in Azure RBAC, manage assignments in Azure Blueprints, or share image galleries.",
    "id": "",
    "name": "",
    "permissions": [
      {
        "actions": [
          "*"
        ],
        "dataActions": [],
        "notActions": [
          "Microsoft.Authorization/*/Delete",
          "Microsoft.Authorization/*/Write",
          "Microsoft.Authorization/elevateAccess/Action",
          "Microsoft.Blueprint/blueprintAssignments/write",
          "Microsoft.Blueprint/blueprintAssignments/delete",
          "Microsoft.Compute/galleries/share/action"
        ],
        "notDataActions": []
      }
    ],
    "roleName": "Contributor",
    "roleType": "BuiltInRole",
    "type": "Microsoft.Authorization/roleDefinitions"
  }
]
```

2. Customize and create the custom role definition as follows (enter your subscription ID in AssignableScopes):
```
az role definition create --role-definition '{
    "Name": "Custom Contributor",
    "Description": "Grants full access to manage all resources, allows you to assign or delete roles in Azure RBAC, but not manage assignments in Azure Blueprints, or share image galleries.",
    "Actions": [
          "*"
        ],
    "DataActions": [],
    "NotActions": [
        "Microsoft.Authorization/elevateAccess/Action",
        "Microsoft.Blueprint/blueprintAssignments/write",
        "Microsoft.Blueprint/blueprintAssignments/delete",
        "Microsoft.Compute/galleries/share/action"
    ],
    "NotDataActions": [],
    "AssignableScopes": ["/subscriptions/xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxxx"]
}'
```

Verify it was created with `az role definition list -n "Custom Contributor"`.

3. Follow [these](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret#creating-a-service-principal) steps to generate your service principal for Terraform, using the `Custom Contributor` role.