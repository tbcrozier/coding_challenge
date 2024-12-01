import csv
from google.cloud import storage
from google.cloud import bigquery

def upload_tsv_to_bq(data, context):
    """
    Cloud Function triggered by a Google Cloud Storage event.

    Args:
        data (dict): Event data containing details about the GCS object.
        context (google.cloud.functions.Context): Metadata about the event.
    """
    bucket_name = data['bucket']
    file_name = data['name']

    # Initialize GCS and BigQuery clients
    storage_client = storage.Client()
    bigquery_client = bigquery.Client()

    # Specify your BigQuery dataset and table
    dataset_id = "tsv_analysis_bqds"
    table_id = "tsv_table"

    # Download the file from GCS
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(file_name)

    print(f"Processing file: {file_name} from bucket: {bucket_name}")

    try:
        # Download the TSV file
        tsv_data = blob.download_as_text()
        tsv_reader = csv.reader(tsv_data.splitlines(), delimiter='\t')

        # Extract the header and rows
        header = next(tsv_reader)  # First row is the header
        rows = [dict(zip(header, row)) for row in tsv_reader]  # Convert rows to dict

        # Insert rows into BigQuery
        table_ref = bigquery_client.dataset(dataset_id).table(table_id)
        errors = bigquery_client.insert_rows_json(table_ref, rows)

        if errors:
            print(f"Errors occurred while inserting rows: {errors}")
        else:
            print(f"Successfully uploaded {len(rows)} rows to {dataset_id}.{table_id}")

    except Exception as e:
        print(f"Error processing file {file_name}: {e}")





