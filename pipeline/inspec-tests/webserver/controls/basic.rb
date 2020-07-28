# copyright: 2020, Chef Software

title "National Parks Web Server"

control "port-1.0" do         
  impact 1.0                  
  title "Webserver Ports Open"
  desc "ports exposed for webserver"
  describe port(8080) do      
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

pin_color = input('color').upcase
control "webpage-1.0" do           
  impact 1.0                       
  title "Web page contains content"
  desc "Web page contains content"
  describe http('http://localhost:8080/national-parks/') do
    its('status') { should cmp 200 }
    its('body') { should include "#{pin_color} ICON" }
  end
end
