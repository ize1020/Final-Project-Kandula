# Mid-Project-Kandula
Mid Project For OpsSchool

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
    * 2 jenkins node
    * 1 eks cluster
  ## public subnet:
    * 1 bastion-ansible
    * 1 jenkins master
        * also ALB on the public




    
