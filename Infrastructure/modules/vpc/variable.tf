variable "vpc_name" {
    type = string
} 

variable "cicd_block" {
    type = string
}

variable "availabilty_zones" {
    type = list(string)
}

variable "subnet_cidrs" {
    type = list(string)
}

variable "cluster_name" {
    description = "name will use for subnet tagging"
    type = string
}