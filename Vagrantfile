# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
  
  config.vm.define "docker_single_host", primary: true do |docker_single_host|
    docker_single_host.vm.box = "centos/7"
    docker_single_host.vm.box_check_update = false
    docker_single_host.vm.network "forwarded_port", guest: 8080, host: 8080, host_ip: "127.0.0.1"
    config.vm.provision "ansible" do |ansible|
      ansible.playbook = "provisioning/docker_host/site.yml"
      ansible.ask_vault_pass = true
    end
  end
end
