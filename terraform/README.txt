this folder contain:
1 - Vpc Module
2 - kuberntis cluster
2 - Bastion Instances that use for ansible
3 - Consul Instances
4 - alb for consul and for jenkins
5 - ./create-config.sh

the script ./create-config.sh going to run:
terraform init
terraform apply -auto-approve

than after he finish he going to inject config file to .shh/ folder on your machine
that going to allow you to connect to all your Instances in your Vpc with the bastion host that use for proxyjump with your secret key.


