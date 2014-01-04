#!/bin/bash
set -e

cp /vagrant/files/puppet.conf /etc/puppet/puppet.conf
puppet apply -vv /vagrant/puppet/manifests/bootstrap.pp
