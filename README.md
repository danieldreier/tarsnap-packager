Package tarsnap into RPMs
-------------------------

This is a very basic approach to packaging tarsnap into RPMs. I love tarsnap, but don't love installing anything that's not packaged on my production systems.

To generate RPMs:

1. install [vagrant](http://docs.vagrantup.com/v2/getting-started/index.html) and [virtualbox](https://www.virtualbox.org/)
2. run `vagrant up` (or `vagrant up centos5` or `vagrant up centos6` if you only need one)
3. get some coffee, this'll take a few minutes
4. check the "packages" folder for packages
5. `vagrant ssh centos6` to ssh into the centos6 (or 5) box to verify for yourself that the package is installed and works
6. `vagrant destroy` to get rid of the virtualbox machines

What's missing
--------------
1. Packages are not GPG signed. I can't redistribute the RPMs because of copyright restrictions on the software, so until the author either allows me to do that or hosts his own signed binaries in a yum repository that won't happen.
2. Code is not GPG verified after download, before compile and packaging. Just haven't gotten to it yet.
3. Testing is very basic. The build script installs the RPMs but doesn't do real testing to ensure functionality.
4. There are no dependencies built into the RPMs (yet)
5. There's no yum repository, so automatic updates aren't possible
6. If a new version is released, you'll need to update the `VERSION` variable in tarsnap-build/tarsnap-rpm-builder.sh
7. Packages are created using [FPM](https://github.com/jordansissel/fpm) so they're definitely not compliant with distro packaging guidelines. They work, but it's pretty basic.

Future plans
------------

Please let me know if you're interested in fedora/debian/ubuntu packages and I'll bump up my priority on adding that functionality. 
