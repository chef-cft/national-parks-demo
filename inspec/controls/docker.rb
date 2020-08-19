# describe habitat_package(origin: 'core', name: 'openssl') do
#     it             { should exist }
#     its('version') { should eq '2.4.35'}
#     its('release') { should eq '20190307151146'}
#   end

package('openssl') do
    it { should be_installed }
end

directory '/hab' do
    it { should exist }
end
