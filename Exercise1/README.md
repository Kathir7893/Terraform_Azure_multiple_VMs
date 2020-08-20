**Steps:**

1. Install Terraform 

2. Clone this repo

3. Navigate to this Exercise1 directory & execute the below command to initialize Terraform:
  
       terraform init

4. In `variables.tf`, Modify the `vm_count` & `vm_names` as per the requirement. If needed change the `env_tag` and `region` as well. 

5. To validate the template:
 
       terraform validate

6. To see the virtual plan of resources:

       terraform plan

7. To apply the plan:
 
       terraform apply


8. To monitor the metrics of created VMs, execute the script `pull_metrics.sh`. 
   This script fetches the metadata of newly created VMs from the terraform state files & pulls the metrics data from the respective VMs

       ./pull_metrics.sh
   
9. To destroy the created resources:

       terraform destroy
