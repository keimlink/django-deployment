# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "boxcutter/debian8"
  config.vm.hostname = "django-deployment-vagrant"

  # Synced folder for Django project
  config.vm.synced_folder ENV.fetch("DJANGO_SOURCE", "src/"), "/src"

  # Port forwarding for HTTP server.
  config.vm.network "forwarded_port", guest: 80, host: 8000, auto_correct: true

  # Salt provisioning.
  config.vm.synced_folder "salt/roots/", "/srv/"
  config.vm.provision :salt do |salt|
    salt.masterless = true
    salt.minion_config = "salt/minion"
    salt.run_highstate = true
  end
end
