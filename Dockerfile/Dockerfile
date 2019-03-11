FROM ubuntu:16.04

RUN apt-get update && apt-get install -y \
  nginx \
  git \
  vim \
  wget \
  curl
RUN /bin/bash -c "$(wget -qO- https://apt.vapor.sh)"
RUN apt-get install -y \
  swift \
  vapor

RUN rm /etc/nginx/nginx.conf
COPY /Dockerfile/vapor.conf /etc/nginx/conf.d
COPY /Dockerfile/nginx.conf /etc/nginx

RUN mkdir /vapor
COPY Package.swift /vapor/Package.swift
COPY Package.resolved /vapor/Package.resolved
COPY Public /vapor/Public
COPY Resources /vapor/Resources
COPY Sources /vapor/Sources
COPY Tests /vapor/Tests

WORKDIR /vapor
RUN swift build
RUN vapor build

EXPOSE 80

# chmod +x startup.sh
COPY /Dockerfile/startup.sh /
ENTRYPOINT ["/startup.sh"]
