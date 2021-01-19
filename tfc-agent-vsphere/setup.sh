#!/bin/sh

export TFC_AGENT_SINGLE=true

docker run -d \
  -e TFC_AGENT_TOKEN \
  -e TFC_AGENT_SINGLE \
  -e VSPHERE_SERVER \
  -e VSPHERE_USER \
  -e VSPHERE_PASSWORD \
  --restart always \
  hashicorp/tfc-agent:latest

docker run -d \
  -e TFC_AGENT_TOKEN \
  -e TFC_AGENT_SINGLE \
  -e VSPHERE_SERVER \
  -e VSPHERE_USER \
  -e VSPHERE_PASSWORD \
  --restart always \
  hashicorp/tfc-agent:latest