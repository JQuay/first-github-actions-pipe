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
  region  = "us-central1"
  zone    = "us-central1-a"
}

# Variables
variable "project_id" {}
variable "ssh_user" {
  default = "terraform-user"
}
variable "public_key_path" {}

# VM resource
resource "google_compute_instance" "vm_instance" {
  name         = "tf-demo-vm"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network = "default"
    access_config {} # assigns ephemeral public IP
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.public_key_path)}"
  }

  tags = ["terraform", "demo"]
}

# Outputs
output "instance_ip" {
  value = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}

output "ssh_command" {
  value = "ssh ${var.ssh_user}@${google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip}"
}
