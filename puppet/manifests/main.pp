stage { 'first': }
stage { 'last': }
Stage['first'] -> Stage['main'] -> Stage['last']

# script to run puppet
file{"/usr/local/bin/runpuppet":
  content => " \
  sudo puppet apply -vv  --modulepath=/vagrant/puppet/modules/ /vagrant/puppet/manifests/main.pp\n",
  mode    => 0755
}

# script to run librarian-puppet
file{"/usr/local/bin/runlibrarian":
  content => "cd /vagrant/puppet && sudo librarian-puppet update \n",
  mode    => 0755
}

import 'basic.pp'
import 'nodes.pp'