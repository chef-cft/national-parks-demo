# copyright: 2018, The Authors

title "National Parks HAProxy"

# you can also use plain tests
# describe file("/tmp") do
#   it { should be_directory }
# end

# you add controls here
control "port-1.0" do                        # A unique ID for this control
  impact 1.0                               # The criticality, if this control fails.
  title "HAProxy Ports Open"             # A human-readable title
  desc "ports exposed for webserver"
  describe port(8085) do                  # The actual test
    it { should be_listening }
  end
end

control "hab-1.0" do                        # A unique ID for this control
  impact 1.0                               # The criticality, if this control fails.
  title "Habitat Installed"             # A human-readable title
  desc "habitat installed"
  describe command('/bin/hab').exist? do
    it { should eq true }
  end
end


control "webpage-1.0" do           
  impact 1.0                       
  title "Web page contains content"
  desc "Web page contains content"
  describe http('http://localhost:8085/national-parks/') do
    its('status') { should cmp 200 }
    its('body') { should match /Map of National Parks/ }
    its('body') { should_not match /redicon/ }
  end
end

# describe habitat_services do
#   its('names') { should include 'config-baseline' }
#   its('names') { should include 'audit-baseline' }
#   its('names') { should include 'national-parks' }
# end

# control "national-parks-service-1.0" do                       
#   impact 1.0                               
#   title "National Parks is running"   
#   desc "config baseline exists"
#   describe habitat_service(origin: 'chef-sa-pipeline', name: 'national-parks') do
#     it { should exist }
#   end
# end