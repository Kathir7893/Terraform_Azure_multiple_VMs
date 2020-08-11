**Steps:**

1. Install Terraform 

2. Clone this repo

3. Navigate to this repo directory & execute the below command to initialize Terraform:
  
       terraform init

4. In `variables.tf`, Modify the `vm_count` & `vm_names` as per the requirement. If needed change the `env_tag` and `region` as well. 

4. To validate the template:

 
       terraform validate

6. To see the virtual plan of resources:


       terraform plan

7. To apply the plan:

 
       terraform apply

8. To destroy the created resources:


       terraform destroy
