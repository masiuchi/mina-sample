# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname = 'trusty64.local'
  config.vm.provision :shell, path: 'provision.sh'
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
end