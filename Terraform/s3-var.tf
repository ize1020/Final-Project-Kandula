variable "remote_state_bucket_name" {
  default     = "itzik-opsschool-final-project-state"
  description = "name for the bucket to store the configuration state remotely"
  type        = string
}

variable "jenkins_bucket_name" {
  default     = "itzik-opsschool-final-project-jenkins"
  description = "name for the bucket to store jenkins configuration"
  type        = string
}
