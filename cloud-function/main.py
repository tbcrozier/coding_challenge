import csv
from google.cloud import storage

def analyze_tsv(data, context):
    bucket_name = data['bucket']
    file_name = data['name']

    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(file_name)

    tsv_data = blob.download_as_text()
    tsv_reader = csv.reader(tsv_data.splitlines(), delimiter='\t')
    header = next(tsv_reader)
    rows = list(tsv_reader)

    row_count = len(rows)
    col_count = len(header)

    print(f"Analyzed TSV File: {file_name}")
    print(f"Columns: {header}")
    print(f"Row count: {row_count}, Column count: {col_count}")

    results_blob = bucket.blob(f"results/{file_name}_analysis.txt")
    results_blob.upload_from_string(
        f"File: {file_name}\nColumns: {header}\nRows: {row_count}\nColumns: {col_count}"
    )
    print(f"Analysis results saved to: results/{file_name}_analysis.txt")


