#!/usr/bin/env bash

add-apt-repository ppa:openjdk-r/ppa -y

apt-get update -q     # q: quiet (omitting progress indicators)
apt-get upgrade -q=2

apt-get install -y openjdk-11-jre-headless

mv /tmp/init/hello.service /etc/systemd/system/hello.service
systemctl start hello
