# aws_test_cookbook

Simple aws cookbook using: **_chef-provisioning-aws driver_**

MAJOR ISSUE:

In attribues.rb, I have to specify vpc, igw, route table id's inorder for entire vpc to connect. How do I dynamically get all id's .... I tried connecting by each component name but error was thrown that resource with id 'name' does not exists...

Ok, so when you create an IGW in chef, then by default it creates data_bag under aws_internet_gateway folder. the json file in there has everything you need to connect a route table!! 
Same applies when creating route_tables and subnets!!!

This is great because I can now get id's dynamically during run_time! All i have to make sure is my run_list is in the correct order :D
