# unzip

This cookbook has a custom resource with a library function to help extract .zip and .gz 
files by providing some info in attributes file.
1. the src (.gz/.zip abs path) 
2. the destination_path ( abs path to extract src to)

The custom resource has a safe gaurd to prevent chef-client to run that resource every time. It will check if the destination_path exists and take action based on that evaluation.


How to use this; (Note this cookbook is not on chef super market yet)
1. Fork this repo
2. Download the repo
3. Place the downloaded cookbook/repo inside your cookbooks directory.
3. Create a wrapper cookbook
4. Inside the wrapper cookbook's metadata.rb -- add -- depends 'unzip', '=0.1.0'
5. Inside the wrapper cookbook's Berksfile -- add -- cookbook 'unzip', path: '../unzip/'
6. Inside the wrapper cookbook's recipe -- add -- include_recipe "unzip::default"
7. Inside the wrapper cookbook's attribute file -- add these attributes with your values!  
        node.default['unzip'] = 
        {
						"src" => "",
						"destination_path" => ""
        }
