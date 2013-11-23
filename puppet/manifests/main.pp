# script to run puppet
file{"/usr/local/bin/runpuppet":
  content => " \
  sudo puppet apply -vv  --modulepath=/vagrant/puppet/modules/ /vagrant/puppet/manifests/main.pp\n",
  mode    => 0755
}

import 'basic.pp'
import 'nodes.pp'