#!/usr/bin/env bash

# bash -c "help set"
# -x: print commands
# -u: errors on unset variables
# -e: exit immediately on error
set -eo pipefail

add-apt-repository ppa:openjdk-r/ppa -y
apt-get update -q     # q: quiet (omitting progress indicators)
apt-get install -y openjdk-11-jre-headless

mv /tmp/init/hello.service /etc/systemd/system/hello.service
systemctl start hello
