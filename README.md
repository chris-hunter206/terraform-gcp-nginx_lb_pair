# terraform-gcp-nginx_lb_pair
This repo will use Terraform to setup a pair of load-balanced VM hosts in
Google Compute Engine. A script will install nginx as a post-build step,
setting up the infrastruture for a basic web hosting application with
geographic zone redundancy.

# Requirements
This assumes you have a few things before the build can start: 
* An existing project in Google Cloud that you can
work within.
* A service account that Terraform can use to build within the project. 
This should have the ```cloud functions service``` role. 
* A credentials.json file on the local filesystem that you will use to
run the build. This information is output when you create the service
account.

# Setup & Installation

1. Gather custom settings information to define variables for your GCP
   project. Specific values you will need are:

* ```project_id```: GCP project_id
* ```credentials_file```: Filesystem path to your credentials.json file
* ```domain```: Domain name the website will be published at
* ```managed_zone_name```: Name of your DNS zone resource in GCP
* ```instance_base_image```: Base Image to create the Linux VM from
* ```machine_type```: GCP machine type for the VMs
* ```region```: GCP global region
* ```zones```: List of GCP zones to use for region redundancy.
* ```service_account_id```: Name of the service account in GCP that terraform will use
* ```service_account_email```: Email address of the service account in GCP that terraform will use
* ```template_name```: A name for the VM instance template you will be creating.

2. Create a text file named ```terraform.tfvars``` using the ```.example```
   file as a template, and populate it with your custom variable settings. 
   
3. Create a text file named ```init.sh``` also using the ```.example``` as a template. 
   Edit the first three values in the file and change to your custom settings.

4. Execute the ```init.sh``` script. This will authenticate with your service
   account and enable required APIs needed for the terraform build.
   
5. Install Terraform if it is not already setup on your build host.

# Build

1. In the ```terraform-gcp-nginx_lb_par``` directory, Run ```terraform init```
   to create the local infrastucture and initialize the provider information.
   
2. Run ```terraform plan``` to verify there are no potential build errors.

3. Run ```terraform apply``` and enter ```yes``` when prompted.

4. When the build is complete, verify you can reach the URL that is output at
   the end of the build.
