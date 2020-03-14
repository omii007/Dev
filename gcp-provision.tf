// Configure the Google Cloud provider
provider "google" {
 credentials = "${file("terraformproject-06022019-a95215f8cc1f.json")}"
 project     = "terraformproject-06022019"
 region      = "asia-south1"
}

//Terraform plugin for creating random ids
//resource "random_id" "instance_id" {
//byte_length = 8
//}

// A single Google Cloud Engine instance
resource "google_compute_instance" "default" {
 name         = "webserver"
 machine_type = "f1-micro"
 zone         = "asia-south1-a"

 boot_disk {
   initialize_params {
     image = "centos-7-v20190515"
   }
 }


// Make sure flask is installed on all new instances for later steps
 metadata_startup_script = "sudo yum update -y; sudo yum install httpd -y"

 network_interface {
   network = "default"

   access_config {
// Include this section to give the VM an external ip address
   }
 }
}

resource "google_compute_firewall" "default" {
 name    = "tomcat-firewall"
 network = "default"
 allow {
  protocol = "tcp"
   ports    = ["8080"]
 }
}


