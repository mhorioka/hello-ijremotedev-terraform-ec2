# About this project

Sample Code to set up and test a remote development environment with IntelliJ based IDE on AWS EC2 using Terraform

# About files in this project
## .tf files and responsibilities
- cloudwatch.tf: CloudWatch dashboard configuration and alarm action (shutdown EC2 instance when CPU utilization is lower than threshold)
- ec2.tf: EC2 instance configuration
- iam.tf: IAM role configuration for CloudWatch
- main.tf: Terraform and AWS provider
- network.tf: VPC configuration
- outputs.tf: Terraform command output
- variables.tf: ssh public key location in local machine, EC2 and CloudWatch configuration

## cloud-init.sh
This script is used to initialize EC2 instance upon creation. It does following:
- Install required OS packages and libraries
- Install JetBrains IDE (Change IDE_URL if you want to try another version)
- Download and setup project developed with JetBrains IDE

# How to use

## Prerequisites
- AWS account
- Terraform and AWS CLI https://learn.hashicorp.com/collections/terraform/aws-get-started

## Configuration and Run
**IMPORTANT** Running IntelliJ based IDE requires enough vCPU and memory. Be sure about how much you would be charged for the EC2 environment you set up. This sample configures CloudWatch alarm action to shut down EC2 instance when CPU utilization is lower than specified threshold for 30 min. 

- Review and edit (if needed) variables.tf for SSH key, EC2 setup, allowed ip address for SSH connection, etc
- Run "terraform init" to initialize your environment
- Run "terraform apply" to create IntelliJ IDEA remote dev environment on your AWS account
  - You can override variables in variable.tf like "terraform apply -var 'aws_profile=my_aws_profile'"
  - Check the external IP address of the EC2 instance from the result of the "terraform apply" command OR AWS console   
  - Connect to the instance with "ssh ec2-user@\<external IP address of the instance>" and wait for cloud-init.sh completes (you can check the progress by "sudo tail -f /var/log/cloud-init-output.log)
  - From EC2 instance, start IntelliJ IDEA remote server (remote-dev-server.sh run <path/to/project> --ssh-link-host \<host>)
  - Connect to IntelliJ IDEA remote server from JetBrains Gateway
  - Access CloudWatch "remotedev-dashboard" dashboard to check CPU, memory, disk utilization in your test environment 
- Run "terraform destroy" to clean up IntelliJ IDEA remote dev environment on your AWS account


# References
- IntelliJ IDEA documentation 
  - EN: https://www.jetbrains.com/help/idea/remote-development-a.html#use_local_ide
  - JP: https://pleiades.io/help/idea/remote-development-a.html#use_local_ide
