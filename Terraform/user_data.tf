locals {
jenkins_home = "/home/ubuntu/jenkins_home"
jenkins_home_mount = "${local.jenkins_home}:/var/jenkins_home"
docker_sock_mount = "/var/run/docker.sock:/var/run/docker.sock"
java_opts = "JAVA_OPTS='-Djenkins.install.runSetupWizard=false'"

 consul_server-userdata = <<USERDATA
#!/usr/bin/env bash
set -e

### set consul version
CONSUL_VERSION="1.8.5"

echo "Grabbing IPs..."
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

echo "Installing dependencies..."
apt-get -qq update &>/dev/null
apt-get -yqq install unzip dnsmasq &>/dev/null

echo "Configuring dnsmasq..."
cat << EODMCF >/etc/dnsmasq.d/10-consul
# Enable forward lookup of the 'consul' domain:
server=/consul/127.0.0.1#8600
EODMCF

systemctl restart dnsmasq

cat << EOF >/etc/systemd/resolved.conf
[Resolve]
DNS=127.0.0.1
Domains=~consul
EOF

systemctl restart systemd-resolved.service

echo "Fetching Consul..."
cd /tmp
curl -sLo consul.zip https://releases.hashicorp.com/consul/1.8.5/consul_1.8.5_linux_amd64.zip

echo "Installing Consul..."
unzip consul.zip >/dev/null
chmod +x consul
mv consul /usr/local/bin/consul

# Setup Consul
mkdir -p /opt/consul
mkdir -p /etc/consul.d
mkdir -p /run/consul
tee /etc/consul.d/config.json > /dev/null <<EOF
{
  "advertise_addr": "$PRIVATE_IP",
  "data_dir": "/opt/consul",
  "datacenter": "isaacE",
  "encrypt": "uDBV4e+LbFW3019YKPxIrg==",
  "disable_remote_exec": true,
  "disable_update_check": true,
  "leave_on_terminate": true,
  "retry_join": ["provider=aws tag_key=consul_server tag_value=true"],
  "server": true,
  "bootstrap_expect": 3,
  "ui": true,
  "client_addr": "0.0.0.0"
}
EOF

# Create user & grant ownership of folders
useradd consul
chown -R consul:consul /opt/consul /etc/consul.d /run/consul


# Configure consul service
sudo tee /etc/systemd/system/consul.service > /dev/null <<"EOF"
[Unit]
Description=Consul service discovery server
Requires=network-online.target
After=network.target

[Service]
User=consul
Group=consul
Restart=on-failure
Environment=GOMAXPROCS=2
ExecStart=/usr/local/bin/consul agent -pid-file=/run/consul/consul.pid -config-dir=/etc/consul.d
ExecReload=/bin/kill -s HUP $MAINPID
KillSignal=SIGINT
TimeoutStopSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable consul.service
sudo systemctl start consul.service

exit 0

USERDATA



  consul_agent-userdata = <<USERDATA
#!/usr/bin/env bash
set -e

### set consul version
CONSUL_VERSION="1.8.5"

echo "Grabbing IPs..."
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

echo "Installing dependencies..."
apt-get -qq update &>/dev/null
apt-get -yqq install nginx 
apt-get -yqq install unzip dnsmasq &>/dev/null

cat << EOF >/etc/systemd/resolved.conf
[Resolve]
DNS=127.0.0.1
Domains=~consul
EOF

systemctl restart systemd-resolved.service

echo "Fetching Consul..."
cd /tmp
curl -sLo consul.zip https://releases.hashicorp.com/consul/1.8.5/consul_1.8.5_linux_amd64.zip

echo "Installing Consul..."
unzip consul.zip >/dev/null
chmod +x consul
mv consul /usr/local/bin/consul

# Setup Consul
mkdir -p /opt/consul
mkdir -p /etc/consul.d
mkdir -p /run/consul
tee /etc/consul.d/config.json > /dev/null <<EOF
{
  "advertise_addr": "$PRIVATE_IP",
  "data_dir": "/opt/consul",
  "datacenter": "isaacE",
  "encrypt": "uDBV4e+LbFW3019YKPxIrg==",
  "disable_remote_exec": true,
  "disable_update_check": true,
  "leave_on_terminate": true,
  "retry_join": ["provider=aws tag_key=consul_server tag_value=true"],
  "enable_script_checks": true,
  "server": false
}
EOF

tee /etc/consul.d/web.json > /dev/null <<EOF
{
  "service": {
    "name": "webserver",
    "tags": [
      "webserver"
    ],
    "port": 80,
    "check": {
      "args": [
        "curl",
        "localhost"
      ],
      "interval": "10s"
    }
  }
}
EOF
# Create user & grant ownership of folders
useradd consul
chown -R consul:consul /opt/consul /etc/consul.d /run/consul


# Configure consul service
tee /etc/systemd/system/consul.service > /dev/null <<"EOF"
[Unit]
Description=Consul service discovery agent
Requires=network-online.target
After=network.target

[Service]
User=consul
Group=consul
Restart=on-failure
Environment=GOMAXPROCS=2
ExecStart=/usr/local/bin/consul agent -pid-file=/run/consul/consul.pid -config-dir=/etc/consul.d
ExecReload=/bin/kill -s HUP $MAINPID
KillSignal=SIGINT
TimeoutStopSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable consul.service
systemctl start consul.service

exit 0


USERDATA


  my-nginx-instance-userdata = <<USERDATA
#!/bin/bash

sudo apt update
sudo apt install nginx awscli -y

# Welcome page changes-
sudo sed -i "s/nginx/Grandpa's Whiskey $(hostname)/g" /var/www/html/index.nginx-debian.html
sudo sed -i '15,23d' /var/www/html/index.nginx-debian.html

# Change Nginx configuration to get real users IP address in Nginx log files-
sudo echo "set_real_ip_from  ${module.vpc_module.vpc_cidr};" >> /etc/nginx/conf.d/default.conf; echo "real_ip_header    X-Forwarded-For;" >> /etc/nginx/conf.d/default.conf

sudo service nginx restart

# Upload web server access logs to S3 every hour-
sudo echo "0 * * * * aws s3 cp /var/log/nginx/access.log s3://opsschool-nginx-access-log" > /var/spool/cron/crontabs/root

### install ansible
sudo apt update && sudo apt install ansible -y
sudo apt-get install python-boto3

USERDATA


  jenkins-master-userdate = <<USERDATA
#!/bin/bash
#update the machine
sudo apt-get update -y

### install ansible
sudo apt update && sudo apt install ansible -y
sudo apt-get install python3-boto3

#install docker
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu
mkdir -p ${local.jenkins_home}
sudo chown -R 1000:1000 ${local.jenkins_home}

#install jenkins
sudo apt install openjdk-11-jdk -y
wget -p -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt install jenkins
sudo systemctl status jenkins
sudo systemctl start jenkins

sudo docker run -d --restart=always -p 8080:8080 -p 50000:50000 -v ${local.jenkins_home_mount} -v ${local.docker_sock_mount} --env ${local.java_opts} jenkins/jenkins

USERDATA
  bastion-userdata = <<USERDATA
#! /bin/bash
sudo apt install software-properties-common -y
sudo apt update
sudo apt-get install ansible -y
sudo apt install unzip -y
sudo apt install python3-pip -y
sudo apt install awscli -y
sudo apt install curl -y
sudo apt install git -y
pip3 install boto3
ansible-galaxy collection install amazon.aws

#CREATE CONFIG FILE
tee /home/ubuntu/.ssh/config > /dev/null <<EOF
Host jenkins
    Hostname 10.0.2.30
    StrictHostKeyChecking no
    StrictHostKeyChecking accept-new
    Port 22
    User ubuntu
    IdentityFile /home/ubuntu/kandula_10.pem
    ForwardAgent yes
    UserKnownHostsFile /dev/null

Host consul1
    Hostname  10.0.2.156
    StrictHostKeyChecking no
    StrictHostKeyChecking accept-new
    Port 22
    User ubuntu
    IdentityFile /home/ubuntu/kandula_10.pem
    ForwardAgent yes
    UserKnownHostsFile /dev/null

Host consul2
    Hostname  10.0.3.230
    StrictHostKeyChecking no
    StrictHostKeyChecking accept-new
    Port 22
    User ubuntu
    IdentityFile /home/ubuntu/kandula_10.pem
    ForwardAgent yes
    UserKnownHostsFile /dev/null

Host consul3
    Hostname  10.0.2.45
    StrictHostKeyChecking no
    StrictHostKeyChecking accept-new
    Port 22
    User ubuntu
    IdentityFile /home/ubuntu/kandula_10.pem
    ForwardAgent yes
    UserKnownHostsFile /dev/null

Host jenkins-node1
    Hostname  10.0.2.50
    StrictHostKeyChecking accept-new
    StrictHostKeyChecking no
    Port 22
    User ubuntu
    IdentityFile /home/ubuntu/kandula_10.pem
    ForwardAgent yes
    UserKnownHostsFile /dev/null

Host jenkins-node2
    Hostname  10.0.3.240
    StrictHostKeyChecking no
    StrictHostKeyChecking accept-new
    Port 22
    User ubuntu
    IdentityFile /home/ubuntu/kandula_10.pem
    ForwardAgent yes
    UserKnownHostsFile /dev/nullv/null

Host agent
    Hostname  10.0.2.20
    StrictHostKeyChecking no
    StrictHostKeyChecking accept-new
    Port 22
    User ubuntu
    IdentityFile /home/ubuntu/kandula_10.pem
    ForwardAgent yes
    UserKnownHostsFile /dev/nullv/null

Host prometheus
    Hostname 10.0.2.85
    StrictHostKeyChecking no
    StrictHostKeyChecking accept-new
    Port 22
    User ubuntu
    IdentityFile /home/isaac/test1/kandula_10.pem
    ForwardAgent yes
    UserKnownHostsFile /dev/null

Host elk
    Hostname 10.0.2.75
    StrictHostKeyChecking no
    StrictHostKeyChecking accept-new
    Port 22
    User ubuntu
    IdentityFile /home/isaac/test1/kandula_10.pem
    ForwardAgent yes
    UserKnownHostsFile /dev/null

EOF

USERDATA

  jenkins_node-userdata = <<USERDATA
#! /bin/bash
apt-get update -y
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.22.6/bin/linux/amd64/kubectl
curl -LO https://dl.k8s.io/v1.22.6/bin/linux/amd64/kubectl.sha256
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
apt-get install docker.io -y
apt  install jq -y
sudo apt install unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
apt install openjdk-11-jre -y
systemctl start docker
systemctl enable docker
usermod -aG docker ubuntu

USERDATA
}

  

