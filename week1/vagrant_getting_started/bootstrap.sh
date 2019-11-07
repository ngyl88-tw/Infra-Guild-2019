#!/usr/bin/env bash

apt-get update
apt-get install -y openjdk-11-jdk

# apt-get install -y apache2
# if ! [ -L /var/www ]; then
#   rm -rf /var/www
#   ln -fs /vagrant /var/www
# fi

mv $(pwd)/hello.service /etc/systemd/system/hello.service
systemctl start hello
