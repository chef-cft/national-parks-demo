control 'National Parks Image Functional Test' do
  impact 1.0
  title 'Validate National Parks Image Runs'
  desc 'Does the container start correctly?'

  describe docker_container('examples_national-parks_1') do
      it { should exist }
      it { should be_running }
      its('ports') { should match /.8080\/tcp/ }
      # its('image') { should eq 'busybox:latest' }
      # its('tag') { should eq 'latest' }
      # its('ports') { should eq [] }
      # its('command') { should eq 'nc -ll -p 1234 -e /bin/cat' }
  end
end

control 'Validate National Parks Image Built Correctly' do
  impact 1.0
  title 'Validate National Parks Image'
  desc 'Is the Docker Image Built Correctly?'

  describe docker.containers do
    its('images') { should include 'niamhcahill/national-parks:7.0.7-20190807162450' }
    its('ports') { should match /.*9631/ }
 end
end

control 'Validate National Parks Container Exposed Ports' do
  impact 1.0
  title 'Check for Insecure Ports on Container Image'
  desc 'Do not expose SSH Port'

  docker.containers.running?.ids.each do |id|
    describe docker.object(id) do
      its('State.Status') { should eq 'running' }
      its(%w(Config ExposedPorts)) { should include '9631/tcp' }
      its(%w(Config ExposedPorts)) { should_not include '22/tcp' }
    end
  end
end
