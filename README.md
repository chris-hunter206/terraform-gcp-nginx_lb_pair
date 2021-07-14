# terraform-gcp-nginx_lb_pair
This repo will use Terraform to setup a pair of load-balanced VM hosts in
Google Compute Engine. A script will install nginx as a post-build step,
setting up the infrastruture for a basic load-balanced web hosting
application with geographic zone redundancy.

## Requirements
This assumes you have a few things before the build can start:
* [Terraform is installed](https://learn.hashicorp.com/tutorials/terraform/install-cli) on your local host
* An existing project in Google Cloud that you can
work within.
* A service account that Terraform can use to build within the project. 
This should have the ```cloud functions service``` role. 
* A credentials.json file on the local filesystem that you will use to
run the build. This information is output when you create the service
account.
* You have the [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)  installed to run ```gcloud``` commands
on your local shell

## Setup & Installation

1. Gather the custom settings information you need to define variables
   for your GCP project. Specific values required are:

* ```project_id```: Your GCP project_id
* ```credentials_file```: Path on your local filesystem to your credentials.json file
* ```domain```: The domain name the website will be published at (Basic dns records A will be created for this zone)
* ```managed_zone_name```: Name of your DNS zone resource in GCP
* ```instance_base_image```: Base Linux image to create the VM from (i.e. ubuntu, centos)
* ```machine_type```: GCP machine type that the VMs will use
* ```region```: Your GCP global region
* ```zones```: List of GCP zones to use for redundancy within the region
* ```service_account_id```: Name of the service account in GCP that terraform will use
* ```service_account_email```: Email address of the service account in GCP that terraform will use
* ```template_name```: A name for the VM instance template you will be creating (this can be arbitrary)

2. Create a text file named ```terraform.tfvars``` using the ```terraform.tfvars.example```
   file as a template, and populate it with your custom variable settings. 
   
3. Create a text file named ```init.sh``` also using the ```init.sh.example``` as a template. 
   Edit the first three values in the file and change to your custom settings.

4. Execute the ```init.sh``` script. This will authenticate with your service
   account and enable required APIs needed for the terraform build. 
   
   Occasionally you may see errors from GCP at this step, and these may clear
   up by re-running the script. The script is idempotent so running it multiple
   times will not cause any issues.
   
## Building the GCP resources

1. In the ```terraform-gcp-nginx_lb_par``` directory, Run ```terraform init```
   to create the local terraform infrastucture files and fetch the required
   provider information.
   
2. Run ```terraform plan``` to verify there are no potential build errors.

3. Run ```terraform apply``` and enter ```yes``` when prompted.

4. When the build is complete, verify you can reach the nginx default page
   via the either the IP address URL or the domain name URL if your DNS
   is active.
