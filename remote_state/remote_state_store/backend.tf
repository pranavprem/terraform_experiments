terraform {
  backend "s3" {
    # Partial configuration. Copy backend.hcl.example to backend.hcl (gitignored).
    # The first apply has to use a local backend, because this stack creates the bucket.
    # See README.md.
  }
}
