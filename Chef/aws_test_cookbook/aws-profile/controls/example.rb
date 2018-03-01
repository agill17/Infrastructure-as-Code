# encoding: utf-8
# copyright: 2017, The Authors

title 'sample section'

# you can also use plain tests
describe file('/tmp') do
  it { should be_directory }
end

# you add controls here
control 'tmp-1.0' do                        # A unique ID for this control
  impact 0.7                                # The criticality, if this control fails.
  title 'Check ec2 is running'             # A human-readable title
  
  describe aws_ec2_instance(name: 'chef_created_ec2_17_11_25__23_54_42') do
    it { should be_running }
    its('image_id') { should eq 'ami-370c225d' }
  end


end
