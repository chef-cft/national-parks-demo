execute 'Run Remediation' do
  command "hab svc load #{node['effortless_dca']['infra_origin']}/#{node['effortless_dca']['infra_package']}"
  action :run
  not_if "hab sup status #{node['effortless_dca']['infra_origin']}/#{node['effortless_dca']['infra_package']}"
end
