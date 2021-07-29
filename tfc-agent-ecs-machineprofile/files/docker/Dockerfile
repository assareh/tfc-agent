FROM hashicorp/tfc-agent

RUN apt-get update && \
  apt-get install python bash curl jq -y && \
  apt-get clean

ADD entrypoint.sh /

# /bin/tfc-agent is the entrypoint from the hashicorp image,
ENTRYPOINT ["/entrypoint.sh"]
#ENTRYPOINT ["/bin/tfc-agent"]
#CMD ["-single"]
