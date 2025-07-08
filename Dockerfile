FROM ubuntu:22.04
RUN apt-get update \
    && apt-get install -y jq curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*