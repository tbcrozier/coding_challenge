output "role" {
  value = google_project_iam_binding.iam_binding.role
}

output "members" {
  value = google_project_iam_binding.iam_binding.members
}
