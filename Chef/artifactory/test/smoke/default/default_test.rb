# # encoding: utf-8

# Inspec test for recipe artifactory::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/


which_java=nil
case os[:family]
when 'redhat'
	which_java = 'java-1.8.0-openjdk-devel'
when 'debian'
	which_java = 'default-jdk'
else
	Chef::Log.warn("Java for #{os[:family]} has not been set yet")
end


unless os.windows?
  # This is an example test, replace with your own test.
  describe user('root'), :skip do
    it { should exist }
  end
end

# This is an example test, replace it with your own test.
describe port(80), :skip do
  it { should_not be_listening }
end


[ 'wget', 'curl', 'tar', 'unzip', 'vim', 'git', 'tree', 'python', 'ruby', which_java].each do |pack|
	describe package(pack) do
		it { should be_installed }
	end
end

describe file('/home/jfrog-artifactory-oss-5.2.1.zip') do
	it { should exist }
	it { should be_file }
	it { should_not be_directory }
end

describe directory('/home/jfrog-artifactory-oss-5.2.1') do
	it { should exist }
	it { should be_directory }
	it { should_not be_file }
end

describe user('artifactory') do
	it { should exist }
	its('home') { should eq '/home/artifactory'}
	its('shell') { should eq '/usr/sbin/nologin'}
end

describe service('artifactory') do
	it { should be_installed }
	it { should be_running }
	it { should be_enabled }
end