#!/bin/sh

apt-get update
apt-get install -qy open-vm-tools docker.io

export TFC_AGENT_SINGLE=true

docker run -d \
  -e TFC_AGENT_TOKEN \
  -e TFC_AGENT_SINGLE \
  --restart always \
  hashicorp/tfc-agent:latest

docker run -d \
  -e TFC_AGENT_TOKEN \
  -e TFC_AGENT_SINGLE \
  --restart always \
  hashicorp/tfc-agent:latest
