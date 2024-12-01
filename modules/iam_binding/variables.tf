variable "project_id" {
  description = "The ID of the project where IAM binding is applied"
  type        = string
}

variable "role" {
  description = "The IAM role to assign"
  type        = string
}

variable "members" {
  description = "List of members to assign the IAM role"
  type        = list(string)
}
