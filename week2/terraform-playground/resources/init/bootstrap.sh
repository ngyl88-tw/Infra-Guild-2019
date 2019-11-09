#!/usr/bin/env bash

apt-get update
apt-get -y upgrade
apt-get install -y openjdk-11-jre-headless

mv /tmp/init/hello.service /etc/systemd/system/hello.service
systemctl start hello
