#!/bin/bash -x

DATUM=`date +%Y%m%d-%H%M%S`

time ansible-galaxy collection install community.general || exit 1
time vagrant plugin install vagrant-vbguest
time vagrant plugin install vagrant-scp
time vagrant destroy -f || exit 1
time vagrant box update || exit 1
export VAGRANT_EXPERIMENTAL="disks"
time vagrant up || exit 1

# find machine id
VMID=`vagrant global-status | grep OoliteBuilder | awk '{print $1}'`

vagrant scp "${VMID}:/home/vagrant/Oolite-Linux-Nightly.*" .
vagrant scp "${VMID}:/home/vagrant/oolite/installers/posix/*.run" .

## assume the last command did shutdown the box
#sleep 70s
#time vagrant halt
