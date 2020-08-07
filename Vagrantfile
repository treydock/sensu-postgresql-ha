# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Environment variables may be used to control the behavior of the Vagrant VM's
# defined in this file. This is intended as a special-purpose affordance and
# should not be necessary in normal situations. If there is a need to run
# multiple p instances simultaneously, avoid the IP conflict by setting
# the ALTERNATE_IP environment variable:
#
#     ALTERNATE_IP=192.168.52.9 vagrant up sensu-p
#
# NOTE: The agent VM instances assume the p VM is accessible on the
# default IP address, therefore using an ALTERNATE_IP is not expected to behave
# well with agent instances.
if not Vagrant.has_plugin?('vagrant-vbguest')
  abort <<-EOM

vagrant plugin vagrant-vbguest >= 0.16.0 is required.
https://github.com/dotless-de/vagrant-vbguest
To install the plugin, please run, 'vagrant plugin install vagrant-vbguest'.

  EOM
end

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end

  config.vm.define "psql1", primary: true, autostart: true do |p|
    p.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "2048"]
    end
    p.vm.box = "centos/7"
    p.vm.hostname = 'psql1.example.com'
    p.vm.network :private_network, ip: '10.0.0.101'
    p.vm.provision :shell, path:"provision_basic_el.sh"
    p.vm.provision :shell, inline: 'puppet agent -t'
  end
  config.vm.define "psql2", primary: true, autostart: true do |p|
    p.vm.box = "centos/7"
    p.vm.hostname = 'psql2.example.com'
    p.vm.network :private_network, ip: '10.0.0.102'
    p.vm.provision :shell, :path => "provision_basic_el.sh"
    p.vm.provision :shell, inline: 'puppet agent -t'
  end
  config.vm.define "psql3", primary: true, autostart: true do |p|
    p.vm.box = "centos/7"
    p.vm.hostname = 'psql3.example.com'
    p.vm.network :private_network, ip: '10.0.0.103'
    p.vm.provision :shell, :path => "provision_basic_el.sh"
    p.vm.provision :shell, inline: 'puppet agent -t'
  end
  config.vm.define "haproxy", primary: true, autostart: true do |p|
    p.vm.box = "centos/7"
    p.vm.hostname = 'haproxy.example.com'
    p.vm.network :private_network, ip: '10.0.0.104'
    p.vm.provision :shell, :path => "provision_basic_el.sh"
    p.vm.provision :shell, inline: 'puppet agent -t'
  end
  config.vm.define "sensu-backend", primary: true, autostart: true do |p|
    p.vm.box = "centos/7"
    p.vm.hostname = 'sensu-backend.example.com'
    p.vm.network :private_network, ip: '10.0.0.105'
    p.vm.provision :shell, :path => "provision_basic_el.sh"
    p.vm.provision :shell, inline: 'puppet agent -t'
  end
end
