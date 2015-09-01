#!/bin/bash

###########################################################
# Configure Mesos One Box
#
# This installs the following components
# - zookeepr
# - mesos master
# - marathon
# - mesos slave
###########################################################

##################
# Install Mesos
##################

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
CODENAME=$(lsb_release -cs)
echo "deb http://repos.mesosphere.io/${DISTRO} ${CODENAME} main" | sudo tee /etc/apt/sources.list.d/mesosphere.list
sudo apt-get -y update
sudo apt-get -y --force-yes install mesosphere

#########################
# Configure ZooKeeper
#########################
echo zk://mesos1:2181/mesos | sudo tee /etc/mesos/zk
echo 1 | sudo tee /etc/zookeeper/conf/myid
echo server.1=mesos1:2888:3888 | sudo tee -a /etc/zookeeper/conf/zoo.cfg

#########################
# Configure Mesos Master
#########################
echo 1 | sudo tee /etc/mesos-master/quorum
hostname -i | sudo tee /etc/mesos-master/ip
hostname | sudo tee /etc/mesos-master/hostname
sudo mkdir -p /etc/marathon/conf
sudo cp /etc/mesos-master/hostname /etc/marathon/conf
sudo cp /etc/mesos/zk /etc/marathon/conf/master
echo zk://mesos1:2181/marathon | sudo tee /etc/marathon/conf/zk
echo 'Mesos One Box' | sudo tee /etc/mesos-master/cluster

#########################
# Configure Mesos Master
#########################
hostname -i | sudo tee /etc/mesos-slave/ip
hostname | sudo tee /etc/mesos-slave/hostname

# restart all processes
sudo restart zookeeper
sudo start mesos-master
sudo start marathon
sudo start mesos-slave
