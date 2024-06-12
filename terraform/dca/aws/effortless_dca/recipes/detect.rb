execute 'Run Audits' do
  command "hab svc load #{node['effortless_dca']['audit_origin']}/#{node['effortless_dca']['audit_package']}"
  action :run
  not_if "hab sup status #{node['effortless_dca']['audit_origin']}/#{node['effortless_dca']['audit_package']}"
end
