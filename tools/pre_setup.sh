#!/bin/bash
set -e

function ensure_package {
  package="$1"

  # Check if the package is installed, and install it if not present
  if hash yum 2>/dev/null; then
    rpm -qi "$package" > /dev/null 2>&1 || yum -y install "$package"
  elif hash apt-get > /dev/null 2>&1; then
    if ! dpkg-query --status "$package" >/dev/null 2>&1; then 
      apt-get update
      apt-get install -y "$package"
    fi
  else
    echo "Yum and apt-get not detected. Unable to install the \"$package\" package."
  fi
}

function ensure_puppet_gpg_key {
  # Check if it's installed already (only on CentOS/RedHat)
  if hash rpm > /dev/null 2>&1 ; then
    rpm -qi gpg-pubkey-4bd6ec30-4ff1e4fa >/dev/null && return
    KEYFILE="$(mktemp)"
   
    ensure_package wget
    wget -O "$KEYFILE" http://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs

    if [ "(sha256sum $KEYFILE)" == '02c7855fd9771c1e105b762ca4f9540cb8b37921f3ba0cc347a3d696229a3340' ]; then
      rpm --import "$KEYFILE"
    fi
  fi


}

lowercase(){
    echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
}

function detect_os {
  # Copied from http://stackoverflow.com/questions/394230/detect-the-os-from-a-bash-script

  OS=`lowercase \`uname\``
  KERNEL=`uname -r`
  MACH=`uname -m`

  if [ "{$OS}" == "windowsnt" ]; then
      OS=windows
  elif [ "{$OS}" == "darwin" ]; then
      OS=mac
  else
      OS=`uname`
      if [ "${OS}" = "SunOS" ] ; then
          OS=Solaris
          ARCH=`uname -p`
          OSSTR="${OS} ${REV}(${ARCH} `uname -v`)"
      elif [ "${OS}" = "AIX" ] ; then
          OSSTR="${OS} `oslevel` (`oslevel -r`)"
      elif [ "${OS}" = "Linux" ] ; then
          if [ -f /etc/redhat-release ] ; then
              DistroBasedOn='RedHat'
              DIST=`cat /etc/redhat-release |sed s/\ release.*//`
              PSUEDONAME=`cat /etc/redhat-release | sed s/.*\(// | sed s/\)//`
              REV=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//`
          elif [ -f /etc/SuSE-release ] ; then
              DistroBasedOn='SuSe'
              PSUEDONAME=`cat /etc/SuSE-release | tr "\n" ' '| sed s/VERSION.*//`
              REV=`cat /etc/SuSE-release | tr "\n" ' ' | sed s/.*=\ //`
          elif [ -f /etc/mandrake-release ] ; then
              DistroBasedOn='Mandrake'
              PSUEDONAME=`cat /etc/mandrake-release | sed s/.*\(// | sed s/\)//`
              REV=`cat /etc/mandrake-release | sed s/.*release\ // | sed s/\ .*//`
          elif [ -f /etc/debian_version ] ; then
              DistroBasedOn='Debian'
              DIST=`cat /etc/lsb-release | grep '^DISTRIB_ID' | awk -F=  '{ print $2 }'`
              PSUEDONAME=`cat /etc/lsb-release | grep '^DISTRIB_CODENAME' | awk -F=  '{ print $2 }'`
              REV=`cat /etc/lsb-release | grep '^DISTRIB_RELEASE' | awk -F=  '{ print $2 }'`
          fi
          if [ -f /etc/UnitedLinux-release ] ; then
              DIST="${DIST}[`cat /etc/UnitedLinux-release | tr "\n" ' ' | sed s/VERSION.*//`]"
          fi
          OS=`lowercase $OS`
          DistroBasedOn=`lowercase $DistroBasedOn`
          readonly OS
          readonly DIST
          readonly DistroBasedOn
          readonly PSUEDONAME
          readonly REV
          readonly KERNEL
          readonly MACH
      fi
  fi
}

function ensure_puppet_repo {
  repo_path=$(mktemp)

  detect_os
  case $DistroBasedOn in
    redhat)
      # Check if it's installed already
      rpm -qi puppetlabs-release > /dev/null 2>&1 && return
      case $REV in
        5.*)
          rpm -ivh http://yum.puppetlabs.com/el/5/products/${MACH}/puppetlabs-release-5-7.noarch.rpm
          ;;
        6.*)
          rpm -ivh http://yum.puppetlabs.com/el/6/products/${MACH}/puppetlabs-release-6-7.noarch.rpm
          ;;
        *)
          echo "Unsupported distro detected"
          exit 1
      esac
      ;;
    debian)
      echo "detected debian based distro"
      if ! dpkg-query --status "puppetlabs-release" >/dev/null 2>&1 ; then
        echo "installing http://apt.puppetlabs.com/puppetlabs-release-${PSUEDONAME}.deb"
        REPO_URL="http://apt.puppetlabs.com/puppetlabs-release-${PSUEDONAME}.deb"
        wget --output-document=${repo_path} ${REPO_URL} #2>/dev/null
        dpkg -i ${repo_path}
        apt-get update
      fi
      ;;
    *)
      echo "Unsupported OS - cannot install puppet repo"
      return 1
      ;;
  esac
  rm ${repo_path}
}

function run_librarian_puppet {
  # This installs puppet modules listed in Puppetfile
  # borrowed from https://github.com/mindreframer/vagrant-puppet-librarian
  # Directory in which librarian-puppet should manage its modules directory
  PUPPET_DIR='/etc/puppet'

  # NB: librarian-puppet might need git installed. If it is not already installed
  # in your basebox, this will manually install it at this point using apt or yum


  ensure_package git
  ensure_package rubygems

  rsync /vagrant/Puppetfile* /etc/puppet/

  if [ `gem query --local | grep librarian-puppet | wc -l` -eq 0 ]; then
    gem install --no-ri --no-rdoc librarian-puppet
    cd $PUPPET_DIR && librarian-puppet install --clean
  else
    cd $PUPPET_DIR && librarian-puppet update
  fi

}

# Install pre-requisites
ensure_package wget

# Install puppet
ensure_puppet_gpg_key
ensure_puppet_repo
ensure_package puppet
cp /vagrant/files/puppet.conf /etc/puppet/puppet.conf

run_librarian_puppet
puppet apply -vv /vagrant/puppet/manifests/main.pp