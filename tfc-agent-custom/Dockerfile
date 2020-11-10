FROM hashicorp/tfc-agent

RUN apt-get update && \
  apt-get install python curl ruby -y && \
  apt-get clean

RUN gem install aws-sdk-secretsmanager -v 1.42.0

# Downloading gcloud package
RUN curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz > /tmp/google-cloud-sdk.tar.gz

# Installing the package
RUN mkdir -p /usr/local/gcloud \
  && tar -C /usr/local/gcloud -xvf /tmp/google-cloud-sdk.tar.gz \
  && /usr/local/gcloud/google-cloud-sdk/install.sh

# Adding the package path to local
ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin

# ADD config-entrypoint.rb /

# /bin/tfc-agent is the entrypoint from the hashicorp image,
# ENTRYPOINT ["/config-entrypoint.rb", "/bin/tfc-agent"]
ENTRYPOINT ["/bin/tfc-agent"]
CMD ["-single"]
