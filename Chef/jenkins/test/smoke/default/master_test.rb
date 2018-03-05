# # encoding: utf-8

# Inspec test for recipe jenkins::master

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/'

unless os.windows?
  # This is an example test, replace with your own test.
  describe user('root'), :skip do
    it { should exist }
  end
end

describe port(80), :skip do
  it { should_not be_listening }
end



################################################
##### 			RHEL+DEB TESTS
################################################

describe group ('jenkins') do
	it { should exist }
end

describe user ('jenkins') do
	it { should exist }
	its('group') { should eq 'jenkins'}
	its('home') { should eq '/var/jenkins'}
end

describe directory('/var/jenkins') do
	it { should exist}
end 



################################################
##### 			RHEL SPECIFIC TESTS
################################################
if os[:family] == 'redhat'
	
	describe yum.repo('jenkins') do
		it { should exist}
		it { should be_enabled}
		its('baseurl') { should eq 'http://pkg.jenkins-ci.org/redhat/'}
	end

	describe package('java-1.8.0-openjdk-devel') do
		it { should be_installed }
	end

	describe file('/etc/sysconfig/jenkins') do
		it {should exist}
		it {should be_file}
		it {should_not be_directory}
		its('content') { should match /JENKINS_USER=\"jenkins\"/}
		its('content') { should match /JENKINS_HOME="\/var\/jenkins"/}
		its('content') { should match /JENKINS_PORT=\"8080\"/}

	end
end



################################################
##### 			DEB SPECIFIC TESTS
################################################
if os[:family] == 'debian'
	describe apt ('http://pkg.jenkins-ci.org/debian/') do
		it { should exist }
		it {should be_enabled}
	end

	describe package('default-jdk') do
		it { should be_installed }
	end

	describe file('/etc/default/jenkins') do
		it {should exist}
		it {should be_file}
		it {should_not be_directory}
		its('content') { should match /NAME=jenkins/}
		its('content') { should match /JENKINS_USER=jenkins/}
		its('content') { should match /JENKINS_GROUP=jenkins/}
		its('content') { should match /JENKINS_HOME=\/var\/jenkins/}
		its('content') { should match /HTTP_PORT=8080/}

	end
end

