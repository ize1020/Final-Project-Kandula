# Mid-Project-Kandula
Mid Project For OpsSchool
![undefined](https://user-images.githubusercontent.com/49163323/168780489-ef305b5a-7243-4f78-845e-d019f39324b6.png)

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
     * copy needed file to bastion-ansible server

## after the script end connect to bastion to run ansible command:
  * cd ansible/
  * ansible-playbook -i hosts  consul/consul_server.yml
  * ansible-playbook -i hosts  consul/consul_agent.yml




    
