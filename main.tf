provider "google" {
  project     = "euphoric-fusion-454304-v6"
  region      = "us-central1"
}

############
terraform {
  required_version = ">= 0.12"
   backend "gcs" {
    bucket  = "my_first_cp_bucket"
    prefix  = "githubactions/state"
  }
}



resource "google_compute_instance" "vm_instance" {
  name         = "my-vm"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {
      // This assigns a public IP
    }
  }

  metadata = {
    ssh-keys = "your-username:ssh-rsa YOUR_SSH_PUBLIC_KEY"
  }
}

# added a comment 
