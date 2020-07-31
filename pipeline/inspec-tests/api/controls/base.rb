# copyright: 2018, The Authors

title "API"

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