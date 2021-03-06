#
# Cookbook Name:: dokku-simple
# Recipe:: default
#
# Copyright 2014, Ric Lister
#
# All rights reserved - Do Not Redistribute
#

## to get the bootstrap script
package 'wget'

## make sure we have apt-add-repository
package 'python-software-properties'
package 'software-properties-common'

tag  = node[:dokku][:tag]
root = node[:dokku][:root]
version = File.join(root, 'VERSION')

## run default dokku install
bash 'dokku-bootstrap' do
  code "wget -qO- https://raw.github.com/progrium/dokku/#{tag}/bootstrap.sh | sudo DOKKU_TAG=#{tag} DOKKU_ROOT=#{root} bash"
  not_if do
    File.exists?(version) and (File.open(version).read.chomp == tag)
  end
end

## loop through users adding all their keys from data_bag users
node[:dokku][:ssh_keys].each do |user, key|
  # TODO make this into an LWRP
  bash "sshcommand_acl-add_key" do
    cwd node['dokku']['root']
    code <<-EOT
      echo '#{key}' | sshcommand acl-add dokku #{user}
    EOT
  end
end

## setup domain, you need this unless host can resolve dig +short $(hostname -f) 
vhost = node[:dokku][:vhost]
if vhost
  file File.join(root, 'VHOST') do
    owner 'dokku'
    content vhost
    action :create
  end
end

## setup env vars for listed apps
node[:dokku][:apps].each do |app, cfg|

  directory File.join(root, app) do
    owner  'dokku'
    group  'dokku'
  end

  template File.join(root, app, 'ENV') do
    source 'ENV.erb'
    owner  'dokku'
    group  'dokku'
    variables(:env => cfg[:env] || {})
  end

end

## initial git push works better if we restart docker first
service 'docker' do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end
