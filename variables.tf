variable "ssh_public_key_file_path" {
  default = "~/.ssh/id_rsa.pub"
}

variable "cloud_init_script_path" {
  default = "./cloud-init.sh"
}

variable "aws_instance_type" {
  //default = "t3a.medium"
  //default = "t3a.xlarge"
  default = "c5a.xlarge"
}

variable "aws_root_volume_type" {
  default = "gp3"
}

variable "aws_root_volume_size" {
  default = "40"
}

variable "aws_profile" {
  default = "default"
}

variable "aws_region" {
  //default = "us-west-2"
  default = "ap-northeast-1"
}

variable "aws_availability_zone" {
  //default = "us-west-2a"
  default = "ap-northeast-1a"
}

variable "cloudwatch_cpu_eval_periods" {
  default = "6"
}

variable "cloudwatch_cpu_eval_period" {
  default = "300"
}

variable "cloudwatch_cpu_utilization_threshold" {
  // for small instance
  //default = "15"

  default = "10"
}

variable "cloudwatch_alarm_action_enabled" {
  default = "true"
}

variable "cidr_blocks_ssh_in" {

  default = null //use MY IP

  //default = "0.0.0.0/0"

}