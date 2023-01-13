FROM hashicorp/tfc-agent

WORKDIR /
RUN apt-get update && \
  apt-get install python bash curl jq -y && \
  apt-get clean

ADD entrypoint.sh /

ENTRYPOINT ["/bin/bash", "-c", "source ./entrypoint.sh"]

