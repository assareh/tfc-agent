FROM hashicorp/tfc-agent:latest

RUN mkdir /home/tfc-agent/.tfc-agent
ADD --chown=tfc-agent:tfc-agent hooks /home/tfc-agent/.tfc-agent/hooks
