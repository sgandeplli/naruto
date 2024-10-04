# Configure the Google Cloud Provider
provider "google" {
  project     = "<your-gcp-project-id>"
  region      = "us-central1"
}

# Create a GCP Virtual Machine (VM)
resource "google_compute_instance" "web_server" {
  name         = "naruto-web-server"
  machine_type = "f1-micro"
  zone         = "us-central1-a"

  # Boot disk image for the instance
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  # Network interface configuration
  network_interface {
    network = "default"

    access_config {
      # This automatically assigns an external IP
    }
  }

  # Metadata for startup script (this installs a web server and pulls the GitHub repo)
  metadata_startup_script = <<-EOT
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y apache2 git
    sudo git clone https://github.com/<your_github_username>/<your_repo_name>.git /var/www/html/
    sudo mv /var/www/html/naruto.html /var/www/html/index.html
    sudo systemctl restart apache2
  EOT

  # Define tags for firewall rules (optional)
  tags = ["http-server"]
}

# Firewall rule to allow HTTP traffic
resource "google_compute_firewall" "default-allow-http" {
  name    = "allow-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}
