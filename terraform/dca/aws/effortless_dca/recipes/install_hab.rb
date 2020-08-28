execute 'Install Habitat' do
  command 'curl https://raw.githubusercontent.com/habitat-sh/habitat/master/components/hab/install.sh | sudo bash'
  action :run
  not_if 'hab -v'
end
