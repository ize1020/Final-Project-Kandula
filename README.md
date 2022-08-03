# Mid-Project-Kandula
Mid Project For OpsSchool
![Final project](https://user-images.githubusercontent.com/49163323/182674332-1c9e4457-cf60-4942-8c79-2586c400d44b.png)

## Requirements 
* AWS admin account
* AWS CLI
* Terraform
* Git

## so lets get start
* First clone my repo [Mid-project](https://github.com/ize1020/Mid-Project-Kandula.git)
* Second clone my kandula-app [kandula-app-8](https://github.com/ize1020/kandula-app-8.git)

## My Infrastructure Include
* Terraform
*   VPC module:
    *  1 main vpc 
    *  2 private subnets
    *  2 public subnets
    *  2 Nat
    *  1 IGW
    *  2 Eip
    *  3 route tables
## EKS
* [EKS module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest)
* Eks cluster and 2 node groups 
* alb with 2 listeners (8080 to Jenkins master and 8500 to consul)

## ect2
* 8 instances (6 on private 2 on public):
  ## private subnet:
    * 3 consul server
    * 1 consul agent
    * 1 jenkins master
    * 2 jenkins node
    * 1 eks cluster
    * 1 prometheus
    * 1 kibana
  ## public subnet:
    * 1 bastion-ansible
    * ALB
  ## Ansible
    * install consul server
    * install consul agent
    * install Docker
  ## K8s
    * secret[not configure yet]
    * svc[not configure yet]
    * pod[not configure yet]

### Executing
* cd to mid-project-Kandula
* run bash create-config.sh
    * script will execute:
     * tf init + tf apply --auto-approve
     * will create config file for ssh connect
     * copy and run the needed file to the ec2 private machine.





    
