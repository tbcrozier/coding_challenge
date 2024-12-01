
resource "google_storage_bucket_object" "tsv-file" {
  name   = "data.tsv" # Name of the file in the bucket
  bucket = google_storage_bucket.trigger_bucket.name
  source = "data/data.tsv" # Path to the local file to upload
}

resource "google_storage_bucket" "trigger_bucket" {
  name     = "tsv-trigger-bucket" # Bucket where TSV files are uploaded
  location = "US"
  force_destroy = true
}

resource "google_storage_bucket" "output_bucket" {
  name     = "tsv-output-bucket" # Bucket where TSV files are uploaded
  location = "US"
  force_destroy = true
}

resource "google_storage_bucket" "function_bucket" {
  name     = "tsv-function-bucket" # Replace with your desired bucket name
  location = "US"
  force_destroy = true
}

resource "google_storage_bucket_object" "function_source" {
  name   = "function.zip"
  bucket = google_storage_bucket.function_bucket.name
  source = "cloud-function/function.zip" # Path to the zipped function code
}

resource "google_cloudfunctions_function" "tsv_analysis" {
  name        = "upload_tsv_to_bq"
  description = "A Cloud Function to analyze TSV files"
  runtime     = "python310"
  entry_point = "upload_tsv_to_bq"
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



resource "google_bigquery_dataset" "dataset" {
  dataset_id                  = "tsv_analysis_bqds"
  friendly_name               = "tsv_analysis_test"
  description                 = "This dataset will hold tsv data"
  location                    = "US"
  default_table_expiration_ms = 3600000

  labels = {
    env = "default"
  }

  access {
    role          = "OWNER"
    user_by_email = google_service_account.bqowner.email
  }

  access {
    role   = "READER"
    domain = "hashicorp.com"
  }
}

resource "google_service_account" "bqowner" {
  account_id = "bqowner"
}



resource "google_bigquery_table" "tsv_table" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "tsv_table"

  time_partitioning {
    type = "DAY"
  }

  labels = {
    env = "default"
  }

  schema = <<EOF
  [
    {
      "name": "Item",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "Item_description",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "Item_price",
      "type": "FLOAT64",
      "mode": "NULLABLE"
    },
    {
      "name": "Item_count",
      "type": "NUMERIC",
      "mode": "NULLABLE"
    },
    {
      "name": "Vendor",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "Vendor_address",
      "type": "STRING",
      "mode": "NULLABLE"
    }
  ]
  EOF

}



module "iam_binding_data_editor" {
  source     = "./modules/iam_binding"
  project_id = "vocal-spirit-372618"         # Replace with your project ID
  role       = "roles/bigquery.dataEditor"  # Replace with the desired role
  members    = [
    "user:crozitb0@gmail.com",
    "serviceAccount:vocal-spirit-372618@appspot.gserviceaccount.com"
      ]
}

module "iam_binding_viewer" {
  source     = "./modules/iam_binding"
  project_id = "vocal-spirit-372618"        # Replace with your project ID
  role       = "roles/viewer"
  members    = [
    "user:crozitb0@gmail.com"
  ]
}