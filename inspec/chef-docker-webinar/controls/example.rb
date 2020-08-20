# # copyright: 2018, The Authors

# title "sample section"

# # you can also use plain tests
# describe file("/tmp") do
#   it { should be_directory }
# end

# # you add controls here
# control "tmp-1.0" do                        # A unique ID for this control
#   impact 0.7                                # The criticality, if this control fails.
#   title "Create /tmp directory"             # A human-readable title
#   desc "An optional description..."
#   describe file("/tmp") do                  # The actual test
#     it { should be_directory }
#   end
#
#
#
require_controls 'cis-docker-benchmark' do
  control 'docker-4.6'
  control 'docker-4.7'
  control 'docker-4.9'
  control 'docker-5.1'
  control 'docker-5.3'
  control 'docker-5.4'
  control 'docker-5.5'
  control 'docker-5.6'
  control 'docker-5.7'
  control 'docker-5.9'
end