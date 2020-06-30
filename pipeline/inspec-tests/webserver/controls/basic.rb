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
  desc "An optional description..."
  describe port(8080) do                  # The actual test
    it { should be_listening }
  end
end
