cookbook_file "#{Chef::Config[:file_cache_path]}/waivers.toml" do
  owner 'root'
  group 'root'
  mode '0755'
  action :create_if_missing
end

execute 'Implementing Waivers' do
  command "hab config apply dca-audit.default $(date +%s) #{Chef::Config[:file_cache_path]}/waivers.toml"
  action :run
  only_if "hab sup status #{node['effortless_dca']['audit_origin']}/#{node['effortless_dca']['audit_package']}"
end

execute 'Reload dca-audit' do
  command "hab svc unload #{node['effortless_dca']['audit_origin']}/#{node['effortless_dca']['audit_package']} && sleep 10 && hab svc load #{node['effortless_dca']['audit_origin']}/#{node['effortless_dca']['audit_package']}"
  action :run
  only_if "hab sup status #{node['effortless_dca']['audit_origin']}/#{node['effortless_dca']['audit_package']}"
end
