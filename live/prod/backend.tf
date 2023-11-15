terraform {
  backend "gcs" {
    bucket = "no-delete-ask-ben-tfstate"
    prefix = "tfstate/bcoutellier/environments/prod/"
  }
}
