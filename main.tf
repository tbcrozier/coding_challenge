
# # resource "google_storage_bucket" "example_bucket" {
# #   name          = "my-sample-bucket" # Replace with your desired bucket name
# #   location      = "US" # Location for the bucket
# #   force_destroy = false # Optional: Allows deletion even if the bucket is not empty
# # }

# # output "bucket_name" {
# #   value = google_storage_bucket.example_bucket.name
# # }

# resource "google_storage_bucket" "coding-challenge-tf" {
#   name          = "landing-bucket-coding-challenge"
#   location      = "US-EAST1"
#   storage_class = "STANDARD"
#   force_destroy = true # Optional: Allows deletion even if the bucket is not empty

#   versioning {
#     enabled = true
#   }

#   lifecycle_rule {
#     action {
#       type = "Delete"
#     }
#     condition {
#       age = 30
#     }
#   }
# }

resource "google_storage_bucket_object" "tsv-file" {
  name   = "data.tsv" # Name of the file in the bucket
  bucket = google_storage_bucket.trigger_bucket.name
  source = "data/data.tsv" # Path to the local file to upload
}

resource "google_storage_bucket" "function_bucket" {
  name     = "tsv-analysis-bucket" # Replace with your desired bucket name
  location = "US"
  force_destroy = true
}

resource "google_storage_bucket" "trigger_bucket" {
  name     = "tsv-upload-bucket" # Bucket where TSV files are uploaded
  location = "US"
  force_destroy = true
}

resource "google_storage_bucket_object" "function_source" {
  name   = "function.zip"
  bucket = google_storage_bucket.function_bucket.name
  source = "cloud-function/function.zip" # Path to the zipped function code
}

resource "google_cloudfunctions_function" "tsv_analysis" {
  name        = "analyze-tsv"
  description = "A Cloud Function to analyze TSV files"
  runtime     = "python310"
  entry_point = "analyze_tsv"
  available_memory_mb = 128

  source_archive_bucket = google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.function_source.name

  # Event trigger for file upload to the bucket
  event_trigger {
    event_type = "google.storage.object.finalize"
    resource   = google_storage_bucket.trigger_bucket.name
  }
}


output "function_name" {
  value = google_cloudfunctions_function.tsv_analysis.name
}

