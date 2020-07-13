# copyright: 2018, The Authors

title "Automate"

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

a2_admin_token = input('a2_admin_token')
a2_url = input('a2_url')
describe http("#{a2_url}/api/v0/applications/service-groups", 
  method: 'GET',
  headers: { 'api-token' => a2_admin_token }, 
  open_timeout: 60, 
  read_timeout: 60, 
  ssl_verify: true, 
  max_redirects: 5 ) do
  its('status') { should eq 200 }
  # its('body') { should include 'token:national-parks' }
end
