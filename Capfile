require 'yaml'

target = ENV['TARGET']
CONFIG = YAML.load_file("config.yml")

unless target.nil?
  unless CONFIG['hosts'].has_key? target
    puts "No such host #{target} in config.yml"
    exit 1
  end
  role :target, CONFIG['hosts'][target]['external_ip']
end

set :user, "ubuntu"
set :rubygems_version, "2.0.3"
ssh_options[:keys] = Dir["./keys/*.pem"]

namespace :chef do

  desc "Initialize chef and basic system"
  task :bootstrap, :roles => :target do
    update_apt
    install_ruby
    install_gems
    set_hostname
    sudo "reboot"
  end

  desc "set hostname based on target name"
  task :set_hostname, :roles => :target do
    run "sudo su -c 'echo \"127.0.0.1     #{target}\" >> /etc/hosts'"
    run "sudo su -c 'echo #{target} > /etc/hostname'"
    sudo "hostname #{target}"
  end

  desc "Update apt, upgrade, and dist-upgrade"
  task :update_apt, :roles => :target do
    sudo "DEBIAN_FRONTEND=noninteractive apt-get -y update"
    sudo "DEBIAN_FRONTEND=noninteractive apt-get -y upgrade"
    sudo "DEBIAN_FRONTEND=noninteractive apt-get -y dist-upgrade"

    sudo "sed -i -e 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config"
    sudo "sed -i -e 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config"
    sudo "service ssh restart"
  end

  desc "Install ruby 1.9.3 and ruby gems"
  task :install_ruby, :roles => :target do
    sudo "DEBIAN_FRONTEND=noninteractive apt-get -y install ruby1.9.3 ruby-dev automake make"
    rgems = "rubygems-#{rubygems_version}"
    ["rm -rf rubygems*", 
     "wget -q http://production.cf.rubygems.org/rubygems/#{rgems}.tgz", 
     "tar -zxf #{rgems}.tgz"].each { |cmd| run "cd /usr/src && sudo #{cmd}" }
    run "cd /usr/src/#{rgems} && sudo ruby setup.rb"
  end

  desc "Install necessary gems"
  task :install_gems, :roles => :target do
    sudo "gem install --no-rdoc --no-ri chef"
    sudo "gem install --no-rdoc --no-ri bundler"
  end

  desc "Update local cookbook on server"
  task :update_cookbook, :roles => :target do
    kitchen = "/home/#{user}/kitchen"
    run "rm -rf #{kitchen}"
    upload "kitchen", kitchen
    
    config = ["file_cache_path '/var/chef-solo'", 
              "cookbook_path '#{kitchen}/cookbooks'", 
              "data_bag_path '#{kitchen}/data_bags'",
              "role_path '#{kitchen}/roles'"].join("\n")
    put config, "/home/#{user}/chef_config.rb"
  end

  desc "Cook recipe based on contents of config.yml"
  task :cook, :roles => :target do
    update_cookbook
    roles = CONFIG['hosts'][target]['roles'].map { |r| "\"role[#{r}]\"" }.join(',')
    tfile = "/home/#{user}/chef.json"
    put "{ \"run_list\": [ #{roles} ] }", tfile 
    run "sudo chef-solo -c chef_config.rb -j #{tfile}"
  end
end
