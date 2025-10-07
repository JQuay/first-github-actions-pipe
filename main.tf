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

variable "project_id" {}
variable "ssh_user" {
  default = "terraform-user"
}
variable "ssh_public_key" {}

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
    access_config {} # ephemeral public IP
  }

  # Inject SSH key via startup script
  metadata_startup_script = <<-EOT
    #!/bin/bash
    useradd -m ${var.ssh_user} || true
    mkdir -p /home/${var.ssh_user}/.ssh
    echo "${var.ssh_public_key}" >> /home/${var.ssh_user}/.ssh/authorized_keys
    chown -R ${var.ssh_user}:${var.ssh_user} /home/${var.ssh_user}/.ssh
    chmod 600 /home/${var.ssh_user}/.ssh/authorized_keys
  EOT

  tags = ["terraform", "demo"]
}

output "instance_ip" {
  value = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}

output "ssh_command" {
  value = "ssh ${var.ssh_user}@${google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip}"
}
