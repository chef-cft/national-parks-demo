# copyright: 2018, The Authors

title "Automate"
a2_admin_token = input('a2_admin_token')
a2_url = input('a2_url')

control "port-1.0" do               
  impact 1.0                        
  title "Automate Ports Open"        
  desc "ports exposed for automate server"
  describe port(22) do            
    it { should be_listening }
  end
  describe port(9631) do            
    it { should be_listening }
  end
  describe port(9638) do            
    it { should be_listening }
  end
  describe port(80) do            
    it { should be_listening }
  end
  describe port(443) do            
    it { should be_listening }
  end
  describe port(4222) do            
    it { should be_listening }
  end
end

control "hab-1.0" do       
  impact 1.0               
  title "Habitat Installed"
  desc "habitat installed"
  describe command('/bin/hab').exist? do
    it { should eq true }
  end
end

# Testing
sleep(10)

# Perform some basic requests against the backend services
{
  'authn-service': {
    path: '/apis/iam/v2/tokens',
  },
  'authz-service': {
    path: '/apis/iam/v2/policy_version',
  },
  'config-mgmt-service': {
    path: '/api/v0/cfgmgmt/version',
  },
  'compliance-service': {
    path: '/api/v0/compliance/reporting/version',
  },
  'ingest-service': {
    path: '/api/v0/ingest/version',
  },
  'local-user-service': {
    path: '/apis/iam/v2/users',
  },
  'notifications-service': {
    path: '/api/v0/notifications/version',
  },
  'teams-service': {
    path: '/apis/iam/v2/teams',
  },
  'automate-gateway': {
    path: '/api/v0/gateway/version',
  },
}.each_with_index do |(service_name, opts), index|
  control "#{service_name}" do       
    impact 1.0               
    title "GET #{opts[:path]}"
    desc "Checks the version endpoint of #{service_name} to make sure it's up and running"

    describe http("#{a2_url}#{opts[:path]}", 
      method: 'GET',
      headers: { 'api-token' => a2_admin_token }, 
      open_timeout: 60, 
      read_timeout: 60, 
      ssl_verify: true, 
      max_redirects: 5 ) do
      its('status') { should eq(opts[:expected_status] || 200) }
    end
  end  
end
