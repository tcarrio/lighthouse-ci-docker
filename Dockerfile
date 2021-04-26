FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app

RUN apt-get update && \
  apt-get install -y gpg wget curl && \
  echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | tee -a /etc/apt/sources.list.d/google.list && \
  wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
  curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
  apt-get update && \
  apt-get install -y nodejs google-chrome-stable && \
  npm install -g yarn@1.22.10 @lhci/cli@0.7.x

CMD ["lhci", "autorun"]
