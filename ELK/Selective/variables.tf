variable "region" {
  description = "Default Region to deploy in"
  type        = string
  default     = "us-east-1" 
}

variable "target_role_arn_string" {
  description = "Arn of role for target account"
  type        = string
  default     = "value"
}

variable "ami" {
  description = "The ami of instance to be created"
  type        = string
  default     = ""  
}

variable "instance_type" {
  description = "The instance type of the instance"
  type        = string
  default     = ""  
}

variable "subnet_id" {
  description = "The subnet "
  type        = string
  default     = ""  
}

variable "storage_type" {
  description = "The storage_type of root volume "
  type        = string
  default     = ""  
}

variable "storage_size" {
  description = "The storage_type of root volume "
  type        = string
  default     = ""  
}

variable "instance_name" {
  description = "Name of the EC2 instance "
  type        = string
  default     = ""  
}

variable "instance_name_elasticsearch" {
  description = "Name of the EC2 instance "
  type        = string
  default     = "elasticsearch_test"  
}

variable "instance_name_node" {
  description = "Name of the EC2 instance "
  type        = string
  default     = "elasticsearch_node-1"  
}

variable "instance_name_node2" {
  description = "Name of the EC2 instance "
  type        = string
  default     = "elasticsearch_node-2"  
}

variable "instance_name_kibana" {
  description = "Name of the EC2 instance "
  type        = string
  default     = "kibana_test"  
}

variable "instance_name_logstash" {
  description = "Name of the EC2 instance "
  type        = string
  default     = "logstash_test"  
}

variable "sg_name" {
  description = "Name of the SG "
  type        = string
  default     = ""  
}

variable "vpc_id" {
  description = "VPC ID "
  type        = string
  default     = ""  
}

variable "vpc_cidr" {
  description = "VPC CIDR range "
  type        = string
  default     = ""  
}

variable "key_pair_name" {
  description = "Pem File name "
  type        = string
  default     = ""  
}

variable "isClustered" {
  description = "Determines if setup is Clustered or Standalone"
  type        = bool
  default     = false
}
