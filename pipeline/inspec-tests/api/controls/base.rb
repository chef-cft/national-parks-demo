# copyright: 2018, The Authors

title "API"

a2_admin_token = input('a2_admin_token')
a2_url = input('a2_url')

control "token-1.0" do       
  impact 1.0               
  title "National Parks token exists"
  desc "Make arbitrary request using National Parks token to ensure exists for Habitat ingest into Automate"

  a2_token = input('a2_token')
  a2_url = input('a2_url')
  describe http("#{a2_url}/api/v0/applications/service-groups", 
    method: 'GET',
    headers: { 'api-token' => a2_token }, 
    open_timeout: 60, 
    read_timeout: 60, 
    ssl_verify: true, 
    max_redirects: 5 ) do
    its('status') { should eq 403 }
    its('body') { should include 'token:national-parks' }
  end
end

control "token-2.0" do       
  impact 1.0               
  title "Admin token exists for pipeline testing"
  desc "Make request using Admin token to ensure exists for pipeline testing. Then test expected service group"

  a2_admin_token = input('a2_admin_token')
  a2_url = input('a2_url')
  describe http("#{a2_url}/api/v0/cfgmgmt/nodes", 
    method: 'GET',
    headers: { 'api-token' => a2_admin_token }, 
    open_timeout: 60, 
    read_timeout: 60, 
    ssl_verify: true, 
    max_redirects: 5 ) do
    its('status') { should eq 200 }
  end
end

# # Testing
# describe http("#{a2_url}#{opts[:path]}", 
#   method: 'GET',
#   headers: { 'api-token' => a2_admin_token }, 
#   open_timeout: 60, 
#   read_timeout: 60, 
#   ssl_verify: true, 
#   max_redirects: 5 ) do
# end

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
