# copyright: 2020, Chef Software

title "National Parks HAProxy"

control "port-1.0" do               
  impact 1.0                        
  title "HAProxy Ports Open"        
  desc "ports exposed for webserver"
  describe port(8085) do            
    it { should be_listening }
  end
  describe port(22) do            
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


control "webpage-1.0" do           
  impact 1.0                       
  title "Web page contains content"
  desc "Web page contains content"
  describe http('http://localhost:8085/national-parks/') do
    its('status') { should cmp 200 }
    its('body') { should include 'BLUE ICON' }
  end
end
