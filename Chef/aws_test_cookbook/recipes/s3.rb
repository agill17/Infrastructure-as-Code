require 'chef/provisioning/aws_driver'
with_driver 'aws'

aws_s3_bucket node['aws']['S3']['bucket_name'] do
	enable_website_hosting false
end
