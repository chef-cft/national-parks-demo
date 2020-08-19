describe docker_container('examples_national-parks_1') do
    it { should exist }
    it { should be_running }
    its('ports') { should match /.8080\/tcp/ }
    # its('image') { should eq 'busybox:latest' }
    # its('tag') { should eq 'latest' }
    # its('ports') { should eq [] }
    # its('command') { should eq 'nc -ll -p 1234 -e /bin/cat' }
  end

describe docker.containers do
  its('images') { should include 'nc-np/national-parks:7.0.10' }
  its('ports') { should include '9631/tcp' }
end

docker.containers.running?.ids.each do |id|
  describe docker.object(id) do
    its('State.Status') { should eq 'running' }
    its(%w(Config ExposedPorts)) { should include '9631/tcp' }
    its(%w(Config ExposedPorts)) { should_not include '22/tcp' }
  end
end
