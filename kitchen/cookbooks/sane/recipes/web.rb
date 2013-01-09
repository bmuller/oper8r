include_recipe "sane"

pkgs = %W(libmysqlclient-dev libxslt-dev libv8-dev ruby1.9.1-dev nginx g++ libcurl4-openssl-dev)
pkgs.each { |pkg| package pkg }

directory "/mnt/nginx/logs" do
  owner "nobody"
  group "root"
  mode "0755"
  action :create
  recursive true
end

sysuser = "appuser"
[ "/home/#{sysuser}/coreapp",
 "/home/#{sysuser}/coreapp/shared",
 "/home/#{sysuser}/coreapp/shared/log",
 "/home/#{sysuser}/coreapp/shared/pids",
 "/home/#{sysuser}/coreapp/shared/system",
 "/home/#{sysuser}/coreapp/releases" ].each do |d|
  directory d do
    owner "#{sysuser}"
    group "#{sysuser}"
    mode "0755"
    action :create
    recursive true    
  end
end

{ "id_dsa" => "0600", "id_dsa.pub" => "0644", "known_hosts" => "0644" }.each { |fname, m|
  template "/home/#{sysuser}/.ssh/#{fname}" do
    source fname
    mode m
    owner "#{sysuser}"
    group "#{sysuser}"
  end
}
