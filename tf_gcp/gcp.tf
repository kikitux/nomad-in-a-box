variable "region" {
  default = "europe-west4"
}

variable "zone" {
  default = "europe-west4-a"
}

variable "project" {
  default = "alvaro-space"
}

variable location_preference {
  description = "The location_preference settings subblock"
  type        = "list"

  default = [{
    zone = "europe-west4-a"
  }]
}

provider "google" {
  credentials ="${file("gcp.json")}"
  project     = "${var.project}"
  region      = "${var.region}"
}
