#!/bin/bash
set -e

function install_puppet_rpm_key {
echo "-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG/MacGPG2 v2.0.17 (Darwin)

mQINBEw3u0ABEAC1+aJQpU59fwZ4mxFjqNCgfZgDhONDSYQFMRnYC1dzBpJHzI6b
fUBQeaZ8rh6N4kZ+wq1eL86YDXkCt4sCvNTP0eF2XaOLbmxtV9bdpTIBep9bQiKg
5iZaz+brUZlFk/MyJ0Yz//VQ68N1uvXccmD6uxQsVO+gx7rnarg/BGuCNaVtGwy+
S98g8Begwxs9JmGa8pMCcSxtC7fAfAEZ02cYyrw5KfBvFI3cHDdBqrEJQKwKeLKY
GHK3+H1TM4ZMxPsLuR/XKCbvTyl+OCPxU2OxPjufAxLlr8BWUzgJv6ztPe9imqpH
Ppp3KuLFNorjPqWY5jSgKl94W/CO2x591e++a1PhwUn7iVUwVVe+mOEWnK5+Fd0v
VMQebYCXS+3dNf6gxSvhz8etpw20T9Ytg4EdhLvCJRV/pYlqhcq+E9le1jFOHOc0
Nc5FQweUtHGaNVyn8S1hvnvWJBMxpXq+Bezfk3X8PhPT/l9O2lLFOOO08jo0OYiI
wrjhMQQOOSZOb3vBRvBZNnnxPrcdjUUm/9cVB8VcgI5KFhG7hmMCwH70tpUWcZCN
NlI1wj/PJ7Tlxjy44f1o4CQ5FxuozkiITJvh9CTg+k3wEmiaGz65w9jRl9ny2gEl
f4CR5+ba+w2dpuDeMwiHJIs5JsGyJjmA5/0xytB7QvgMs2q25vWhygsmUQARAQAB
tEdQdXBwZXQgTGFicyBSZWxlYXNlIEtleSAoUHVwcGV0IExhYnMgUmVsZWFzZSBL
ZXkpIDxpbmZvQHB1cHBldGxhYnMuY29tPokCPgQTAQIAKAIbAwYLCQgHAwIGFQgC
CQoLBBYCAwECHgECF4AFAk/x5PoFCQtIMjoACgkQEFS3okvW7DAIKQ/9HvZyf+LH
VSkCk92Kb6gckniin3+5ooz67hSr8miGBfK4eocqQ0H7bdtWjAILzR/IBY0xj6OH
KhYP2k8TLc7QhQjt0dRpNkX+Iton2AZryV7vUADreYz44B0bPmhiE+LL46ET5ITh
LKu/KfihzkEEBa9/t178+dO9zCM2xsXaiDhMOxVE32gXvSZKP3hmvnK/FdylUY3n
WtPedr+lHpBLoHGaPH7cjI+MEEugU3oAJ0jpq3V8n4w0jIq2V77wfmbD9byIV7dX
cxApzciK+ekwpQNQMSaceuxLlTZKcdSqo0/qmS2A863YZQ0ZBe+Xyf5OI33+y+Mr
y+vl6Lre2VfPm3udgR10E4tWXJ9Q2CmG+zNPWt73U1FD7xBI7PPvOlyzCX4QJhy2
Fn/fvzaNjHp4/FSiCw0HvX01epcersyun3xxPkRIjwwRM9m5MJ0o4hhPfa97zibX
Sh8XXBnosBQxeg6nEnb26eorVQbqGx0ruu/W2m5/JpUfREsFmNOBUbi8xlKNS5CZ
ypH3Zh88EZiTFolOMEh+hT6s0l6znBAGGZ4m/Unacm5yDHmg7unCk4JyVopQ2KHM
oqG886elu+rm0ASkhyqBAk9sWKptMl3NHiYTRE/m9VAkugVIB2pi+8u84f+an4Hm
l4xlyijgYu05pqNvnLRyJDLd61hviLC8GYU=
=qHKb
-----END PGP PUBLIC KEY BLOCK-----" > /tmp/RPM-GPG-KEY-puppetlabs
  rpm --import /tmp/RPM-GPG-KEY-puppetlabs 
}
function install_puppet {
  # This bootstraps Puppet on CentOS 6.x
  # It has been tested on CentOS 6.4 64bit

  REPO_URL="http://yum.puppetlabs.com/el/6/products/x86_64/puppetlabs-release-6-7.noarch.rpm"

  if [ "$EUID" -ne "0" ]; then
    echo "This script must be run as root." >&2
    exit 1
  fi

  if which puppet > /dev/null 2>&1; then
    echo "Puppet is already installed."
    exit 0
  fi

  # Install puppet labs repo
  echo "Configuring PuppetLabs repo..."
  repo_path=$(mktemp)
  wget --output-document=${repo_path} ${REPO_URL} #2>/dev/null
  rpm -i ${repo_path} # >/dev/null

  # Install Puppet...
  echo "Installing puppet"
  yum install -y puppet # > /dev/null

  echo "Puppet installed!"
}

# Install puppet
rpm -qi gpg-pubkey-4bd6ec30-4ff1e4fa > /dev/null || install_puppet_rpm_key
rpm -qi puppet > /dev/null || install_puppet