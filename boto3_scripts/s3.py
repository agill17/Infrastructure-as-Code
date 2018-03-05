import boto3
import os
import random

def get_all_bucket_names():
	s3 = boto3.client('s3')
	bucket_names = []
	all_buckets = s3.list_buckets()
	for each_bucket in all_buckets['Buckets']:
		bucket_names.append(each_bucket['Name'])

	return bucket_names


def bucket_exists(name):
	s3 = boto3.client('s3')
	bucket_names = get_all_bucket_names()
	if name in bucket_names:
		print ("INFO: The bucket '%s' exists" % name)
		return True
	else:
		print ("INFO: The bucket '%s' does not exists" % name)
		return False


def create_bucket(name):
	s3 = boto3.client('s3')
	exists = bucket_exists(name)
	if name != None and exists == False:
		s3.create_bucket(Bucket=name)
		print ("INFO: Created new s3 bucket: %s" % name)


def create_folder_in_bucket(bucket_name, acl, folder_name = 'test_bucket'):
	s3 = boto3.client('s3')
	if bucket_exists(bucket_name):
		s3.put_object(Bucket=bucket_name,Key=folder_name+'/')
		s3.put_object_acl(ACL=acl, Bucket=bucket_name, Key=folder_name+'/')
		print("INFO: New Object has been placed: %s" % folder_name)
	else:
		print ('ERROR: Bucket %s does not exist!!!' % bucket_name)


def delete_bucket(name):
	s3 = boto3.client('s3')
	buckets = get_all_bucket_names()
	if bucket_exists(name):
	 	### clean up the entire mess in that bucket first
	 	bucket_index = buckets.index(name)
	 	objs = s3.list_objects(Bucket=buckets[bucket_index])
	 	if objs.get('Contents') != None:
	 		print ("INFO: Cleaning up all objects inside the bucket")
			for each_obj in objs['Contents']:
				print ("WARN: Deleting %s" % each_obj['Key'])
				s3.delete_object(Bucket=name, Key=each_obj['Key'])
		else:
			print ("SKIP: Bucket is already empty!")
	 	s3.delete_bucket(Bucket=name)
	 	print ("INFO: Bucket %s deleted!" % name)


def upload_to_s3(file, bucket, folder=None):
	if bucket_exists(bucket) and os.path.isfile(file):
		if '/' in file:
			### if passed as an abs path -> get the file name for key
			### Do not re-create the abs path structure in s3 -- EH
			s3 = boto3.client('s3')
			obj_to_upload = open(file, 'rb')
			name= file.split('/')[-1]
			s3.upload_fileobj(obj_to_upload, bucket, name)
	else:
		raise Exception("Does the File Exists? Does the Bucket exists?")


#delete_bucket('amrit-test-boto3-bucket2')
create_bucket("amrit-test-boto3-bucket2")
for x in range(1,10):
	create_folder_in_bucket("amrit-test-boto3-bucket2", 'public-read', 'test-folder-'+str(x))
upload_to_s3('/Users/amritgill/Python/Automating_the_boring_stuff/lists.py','amrit-test-boto3-bucket2')
# delete_bucket("amrit-test-boto3-bucket2")


