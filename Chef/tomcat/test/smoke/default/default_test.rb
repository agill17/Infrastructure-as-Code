# # encoding: utf-8

# Inspec test for recipe tomcat::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

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




if os[:family] == 'debian'

	describe package('default-jdk') do
		it { should be_installed}
	end

	describe group('tomcat') do
		it { should exist }
	end

	describe user('tomcat') do
		it  { should exist }
		its('group'){ should eq 'tomcat'}
		its('home'){should eq '/opt/tomcat'}
		its('shell'){should eq '/bin/false'}
	end

	describe file('/home/apache-tomcat-8.0.47.tar.gz') do
		it { should exist }
		it { should be_file}
		it { should_not be_directory}
	end

	describe directory('/opt/tomcat/webapps') do
		it { should exist }
		it { should_not be_file }
		it { should be_directory }
	end

	describe file('/etc/systemd/system/tomcat.service') do
		it { should exist }
		it { should_not be_directory}
		its('content'){ should match('512M')}
		its('content'){ should match('1024M')}
	end

	describe file('/opt/tomcat/conf/server.xml') do
		it { should exist}
		it { should be_file }
		it { should_not be_directory }
		its('content'){ should match("Connector port=\"7070\"") }
	end

	describe service('tomcat') do
		it { should be_running }
		it { should be_enabled }
	end


	# describe file('/opt/tomcat/webapps/addressbook-2.0.war') do
	# 	it { should exist }
	# 	it { should be_file }
	# 	it { should_not be_directory }
	# end

elsif os[:family] == 'rhel'
	Chef::Log.warn("RHEL PLATFORM TESTS HAS NOT BE CREATED YET!!!")
end