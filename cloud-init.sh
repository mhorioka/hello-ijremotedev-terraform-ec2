#!/bin/bash
yum update -y
yum install -y git

#JDK
#amazon-linux-extras install corretto8 -y
#yum install -y java-1.8.0-amazon-corretto-devel
yum install -y java-11-amazon-corretto-headless

#CloudWatch
yum install -y amazon-cloudwatch-agent
#yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
#yum install -y collectd

# Write Cloudwatch agent configuration file
cat >> /opt/aws/amazon-cloudwatch-agent/bin/my_config.json <<\EOF
{
	"agent": {
		"metrics_collection_interval": 60,
		"run_as_user": "root"
	},
	"metrics": {
		"metrics_collected": {
			"cpu": {
				"measurement": [
					"cpu_usage_idle",
					"cpu_usage_iowait",
					"cpu_usage_user",
					"cpu_usage_system"
				],
				"metrics_collection_interval": 60,
				"totalcpu": false
			},
			"disk": {
				"measurement": [
					"used_percent",
					"inodes_free"
				],
				"metrics_collection_interval": 60,
				"resources": [
					"*"
				]
			},
			"diskio": {
				"measurement": [
					"io_time"
				],
				"metrics_collection_interval": 60,
				"resources": [
					"*"
				]
			},
			"mem": {
				"measurement": [
					"mem_used_percent"
				],
				"metrics_collection_interval": 60
			},
			"swap": {
				"measurement": [
					"swap_used_percent"
				],
				"metrics_collection_interval": 60
			}
		}
	}
}
EOF

#https://youtrack.jetbrains.com/articles/IDEA-A-2/Inotify-Watches-Limit
echo "fs.inotify.max_user_watches=524288" >> /etc/sysctl.conf
sudo sysctl -p --system

#start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/my_config.json

#set up remote IDE backend and project
#IDE_URL=https://download.jetbrains.com/idea/ideaIU-2021.3.2.tar.gz
IDE_URL=https://download.jetbrains.com/idea/ideaIU-221.4501.155.tar.gz
LOGIN_USER=ec2-user
LOGIN_GROUP=ec2-user
LOGIN_USER_HOME=/home/${LOGIN_USER}
IDE_HOME=${LOGIN_USER_HOME}/ide
TEMP_IDE_FILE=/tmp/ide.tar.gz
PROJECT_URL=https://github.com/spring-projects/spring-petclinic
PROJECT_DIR=${LOGIN_USER_HOME}/spring-petclinic

#clone project code
cd $LOGIN_USER_HOME
sudo -u $LOGIN_USER git clone $PROJECT_URL $PROJECT_DIR
#download dependencies needed in advance
cd $PROJECT_DIR
sudo -u $LOGIN_USER ./mvnw -ntp package

#download IntelliJ IDEA and extract
cd $LOGIN_USER_HOME
curl -fsSL -o $TEMP_IDE_FILE $IDE_URL
mkdir $IDE_HOME
tar xfz $TEMP_IDE_FILE --strip-components=1 -C $IDE_HOME
rm $TEMP_IDE_FILE
chown -R ${LOGIN_USER}:${LOGIN_GROUP} $IDE_HOME
#install plugins
#Following command installs Japanese Language Pack. You can know a Plugin ID(com.intellij.ja) to install from JetBrains
# marketplace page like:
# https://plugins.jetbrains.com/plugin/13964-japanese-language-pack------/versions/stable/149293
sudo -u $LOGIN_USER ide/bin/remote-dev-server.sh installPlugins $PROJECT_DIR com.intellij.ja

#to start remote IDE backend, run the following command
#sudo -u ec2-user ide/bin/remote-dev-server.sh run spring-petclinic --ssh-link-host $(curl -q http://169.254.169.254/latest/meta-data/public-ipv4)
echo "Run the following command to start IntelliJ Remote Server:"
echo "ide/bin/remote-dev-server.sh run $PROJECT_DIR --ssh-link-host \$(curl -q http://169.254.169.254/latest/meta-data/public-ipv4)"