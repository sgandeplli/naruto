# Configure the Google Cloud Provider
provider "google" {
  project     = "primal-gear-436812-t0"
  region      = "us-central1"
}

# Create a GCP Virtual Machine (VM) with CentOS 9
resource "google_compute_instance" "web_server" {
  name         = "naruto-web-server"
  machine_type = "e2-medium"
  zone = "us-central1-a"

  # Boot disk image for CentOS 9
  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-stream-9"
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
    sudo dnf update -y
    sudo dnf install -y httpd git
    sudo systemctl start httpd
    sudo systemctl enable httpd
    sudo git clone https://github.com/sgandeplli/naruto.git /var/www/html/
    sudo mv /var/www/html/naruto.html /var/www/html/index.html
    sudo systemctl restart httpd
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
