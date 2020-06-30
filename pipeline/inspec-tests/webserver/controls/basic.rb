# copyright: 2018, The Authors

title "National Parks Web Server"

# you can also use plain tests
# describe file("/tmp") do
#   it { should be_directory }
# end

# you add controls here
control "port-1.0" do                        # A unique ID for this control
  impact 1.0                               # The criticality, if this control fails.
  title "Webserver Ports Open"             # A human-readable title
  desc "ports exposed for webserver"
  describe port(8080) do                  # The actual test
    it { should be_listening }
  end
end

control "hab-1.0" do                        # A unique ID for this control
  impact 1.0                               # The criticality, if this control fails.
  title "Habitat Installed"             # A human-readable title
  desc "habitat installed"
  describe package('habitat') do                  # The actual test
    it { should be_installed }
  end
end

control "html-1.0" do                        # A unique ID for this control
  impact 1.0                               # The criticality, if this control fails.
  title "HTML Red Pins"             # A human-readable title
  desc "Web page contains red pins"
  describe package('habitat') do                  # The actual test
    it { should be_installed }
  end
end


control "audit-baseline-1.0" do                        # A unique ID for this control
  impact 1.0                               # The criticality, if this control fails.
  title "audit baseline exists"             # A human-readable title
  desc "audit baseline exists"
  describe habitat_service(origin: 'effortless', name: 'audit-baseline') do
    it             { should exist }
  end
end

control "config-baseline-1.0" do                        # A unique ID for this control
  impact 1.0                               # The criticality, if this control fails.
  title "config baseline exists"             # A human-readable title
  desc "config baseline exists"
  describe habitat_service(origin: 'effortless', name: 'config-baseline') do
    it             { should exist }
  end
end


control "webpage-1.0" do                        # A unique ID for this control
  impact 1.0                               # The criticality, if this control fails.
  title "Web page contains content"             # A human-readable title
  desc "Web page contains content"
  describe command('curl http://localhost:8080/national-parks/') do
    its('stdout') { should match (/redicon.png/) }
  end
end