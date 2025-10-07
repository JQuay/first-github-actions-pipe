terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }

  required_version = ">= 1.5.0"
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Variables (inline)
variable "project_id" {}
variable "region" { default = "us-central1" }
variable "zone" { default = "us-central1-a" }
variable "vm_name" { default = "simple-vm" }
variable "machine_type" { default = "e2-micro" }
variable "ssh_user" { default = "terraform-user" }
variable "public_key_path" { default = "~/.ssh/id_rsa.pub" }

# VM resource
resource "google_compute_instance" "vm" {
  name         = var.vm_name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network = "default"
    access_config {} # ephemeral public IP
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.public_key_path)}"
  }

  tags = ["terraform-simple"]
}

# Outputs
output "public_ip" {
  value = google_compute_instance.vm.network_interface[0].access_config[0].nat_ip
}

output "ssh_command" {
  value = "ssh ${var.ssh_user}@${google_compute_instance.vm.network_interface[0].access_config[0].nat_ip}"
}
