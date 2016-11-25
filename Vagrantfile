# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.provision :shell, path: 'provision.sh'

  if config.hostmanager
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
  end

  config.vm.define 'vm1' do |vm1|
    vm1.vm.hostname = 'vm1.local'
    vm1.vm.network 'private_network', ip: '192.168.33.166'
  end

  config.vm.define 'vm2' do |vm2|
    vm2.vm.hostname = 'vm2.local'
    vm2.vm.network 'private_network', ip: '192.168.33.167'
  end
end
