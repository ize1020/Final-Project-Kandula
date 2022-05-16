#! /bin/bash

terraform init
terraform apply -auto-approve

echo "get servers"
BASTION_IP=$(terraform output Bastion-ansible_public_addresses)
consul_server1=$(terraform output consul_servers_1)
consul_server2=$(terraform output consul_servers_2)
consul_server3=$(terraform output consul_servers_3)
jenkins_public_server=$(terraform output Jenkins-Master-public_addresses)
echo "get ips"
bastion=$(echo ${BASTION_IP} | sed 's/"//g')
consul1=$(echo ${consul_server1} | sed 's/"//g')
consul2=$(echo ${consul_server2} | sed 's/"//g')
consul3=$(echo ${consul_server3} | sed 's/"//g')
jenkins_public=$(echo ${jenkins_public_server} | sed 's/"//g')


echo "create config"
cat <<EOT > ~/.ssh/config
Host bastion-ansible
    StrictHostKeyChecking no
    StrictHostKeyChecking accept-new
    HostName ${bastion-ansible}
    User ubuntu
    ForwardAgent yes
    UserKnownHostsFile /dev/null
    IdentityFile /home/isaac/test1/kandula_10.pem

Host jenkins_public
    Hostname ${jenkins_public}
    StrictHostKeyChecking no
    StrictHostKeyChecking accept-new
    Port 22
    User ubuntu
    ProxyJump ${bastion-ansible}
    IdentityFile /home/isaac/test1/kandula_10.pem
    ForwardAgent yes
    UserKnownHostsFile /dev/null

Host consul1
    Hostname  ${consul1}
    StrictHostKeyChecking no
    StrictHostKeyChecking accept-new
    Port 22
    User ubuntu
    ProxyJump ${bastion-ansible}
    IdentityFile /home/isaac/test1/kandula_10.pem
    ForwardAgent yes
    UserKnownHostsFile /dev/null

Host consul2
    Hostname  ${consul2}
    StrictHostKeyChecking no
    StrictHostKeyChecking accept-new
    Port 22
    User ubuntu
    ProxyJump ${bastion-ansible}
    IdentityFile /home/isaac/test1/kandula_10.pem
    ForwardAgent yes
    UserKnownHostsFile /dev/null

Host consul3
    Hostname  ${consul3}
    StrictHostKeyChecking no
    StrictHostKeyChecking accept-new
    Port 22
    User ubuntu
    ProxyJump ${bastion-ansible}
    IdentityFile /home/isaac/test1/kandula_10.pem
    ForwardAgent yes
    UserKnownHostsFile /dev/null

Host jenkins-node1
    Hostname  10.0.2.50
    StrictHostKeyChecking accept-new
    StrictHostKeyChecking no
    Port 22
    User ubuntu
    ProxyJump ${bastion-ansible}
    IdentityFile /home/isaac/test1/kandula_10.pem
    ForwardAgent yes
    UserKnownHostsFile /dev/null

Host jenkins-node2
    Hostname  10.0.3.240
    StrictHostKeyChecking no
    StrictHostKeyChecking accept-new
    Port 22
    User ubuntu
    ProxyJump ${bastion-ansible}
    IdentityFile /home/isaac/test1/kandula_10.pem
    ForwardAgent yes
    UserKnownHostsFile /dev/null

EOT

chmod 400 /home/isaac/test1/kandula_10.pem
cp /home/isaac/test1/kandula_10.pem /home/isaac/.ssh/
scp -oProxyJump=bastion-ansible /home/isaac/test1/kandula_10.pem bastion-ansible:~
scp -r -oProxyJump=bastion-ansible /home/isaac/test1/ansible bastion-ansible:~
scp -oProxyJump=bastion-ansible /home/isaac/test1/ansible/hosts bastion-ansible:~
scp -oProxyJump=bastion-ansible /home/isaac/test1/ansible/ansible.cfg bastion-ansible:~
scp -oProxyJump=bastion-ansible /home/isaac/.ssh/config bastion-ansible:~
#ssh -oProxyJump=bastion-ansible -t ansible 'ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ~/ansible/inventory_aws_ec2.yml --private-key ~/kandula_10.pem  ~/ansible/consul/consul_setup.yml'
#ssh -oProxyJump=bastion-ansible -t ansible 'ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ~/ansible/inventory_aws_ec2.yml --private-key ~/kandula_10.pem  ~/ansible/consul/agent_setup.yml'
