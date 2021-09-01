variable "iam_teams" {
  default = {
    "team1" = {
      "gsa" : "gsa-tfc-team1",
      "namespace" : "tfc-team1",
      "k8a_sa" : "tfc-agent-dev",
      "roles" : ["compute.admin","storage.objectAdmin"],
    },
    "team2" = {
      "gsa" : "gsa-tfc-team2",
      "namespace" : "tfc-team2",
      "k8a_sa" : "tfc-agent-dev",
      "roles" : ["storage.objectAdmin"],
    }
  }
}

variable "bq_iam_role_bindings" {

  default = {
    "member1" = {
      "dataset1" : ["role1","role2", "role5"],
      "dataset2" : ["role3","role2"],
    },
    "member2" = {
      "dataset3" : ["role1","role4"],
      "dataset2" : ["role5"],
    } 
  }
}

locals {
  team_roles = flatten([for team, value in var.iam_teams:
                   flatten([for role in value.roles:
                    {"team" = team
                    "role" = role}
                   ])
                ])

  helper_list = flatten([for member, value in var.bq_iam_role_bindings:
                 flatten([for dataset, roles in value: 
                           [for role in roles:
                            {"member" = member
                            "dataset" = dataset
                            "role" = role}
                         ]])
                   ])
}

output "tf_out" {
  value = local.helper_list2
}

output "tf-test {
  value = flatten([ for team, value in var.iam_teams:
  { "team" = team}])
}
