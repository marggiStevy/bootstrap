terraform {
  backend "gcs" {
    bucket = "no-delete-ask-ben-tfstate"
    prefix = "tfstate/smarggi/environments/prod/"
  }
}
