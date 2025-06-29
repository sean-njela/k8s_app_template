# ✨ Remote state: store the plan & state files in a versioned GCS bucket.
#   – Create the bucket once   :  gsutil mb -b on gs://<YOUR_STATE_BUCKET>
#   – Enable object‑versioning :  gsutil versioning set on gs://<YOUR_STATE_BUCKET>
#   – Init Terraform like     :  terraform init \↩
#         -backend-config="bucket=<YOUR_STATE_BUCKET>" \↩
#         -backend-config="prefix=gke/staging"
terraform {
  backend "gcs" {
    # Replace the next line *once* when you bootstrap; afterwards it is stored in the .terraform directory
    bucket = "<YOUR_STATE_BUCKET>"
    prefix = "gke/staging"
  }
}