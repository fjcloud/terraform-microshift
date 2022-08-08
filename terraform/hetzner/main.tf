# main.tf

####
# Variables
##

variable "hcloud_token" {
  description = "Hetzner Cloud API Token"
  type = string
}

variable "ssh_public_key_name" {
  description = "Name of your public key to identify at Hetzner Cloud portal"
  type = string
  default = "ssh_microshift"
}

variable "ssh_public_key" {
  description = "Local path to your public key"
  type = string
}

variable "hcloud_server_type" {
  description = "vServer type name, lookup via `hcloud server-type list`"
  type = string
  default = "cx11"
}

variable "hcloud_server_datacenter" {
  description = "Desired datacenter location name, lookup via `hcloud datacenter list`"
  type = string
  default = "fsn1-dc14"
}

variable "hcloud_server_name" {
  description = "Name of the server"
  type = string
  default = "microshift"
}

variable "ignite_file" {
  description = "Name of the server"
  type = string
  default = "microshift"
}

####
# Infrastructure config
##

resource "hcloud_ssh_key" "key" {
  name = var.ssh_public_key_name
  public_key = var.ssh_public_key
}

provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_server" "microshift" {
  name = var.hcloud_server_name
  labels = { "os" = "coreos" }

  server_type = var.hcloud_server_type
  datacenter = var.hcloud_server_datacenter

  # Image is ignored, as we boot into rescue mode, but is a required field
  image = "fedora-36"
  rescue = "linux64"
  ssh_keys = [hcloud_ssh_key.key.id]

  connection {
    host = hcloud_server.microshift.ipv4_address
    timeout = "5m"
    agent = false
    private_key = file("~/.ssh/id_rsa")
    # Root is the available user in rescue mode
    user = "root"
  }

  # Copy config.yaml and replace $ssh_public_key variable
  provisioner "file" {
    content = base64decode(var.ignite_file)
    destination = "/root/microshift.ign"
  }

  # Install Fedora CoreOS in rescue mode
  provisioner "remote-exec" {
    inline = [
      "set -x",
      "curl -o /usr/local/bin/coreos-installer https://mirror.openshift.com/pub/openshift-v4/clients/coreos-installer/latest/coreos-installer_amd64",
      "chmod +x /usr/local/bin/coreos-installer",
      # Download and install Fedora CoreOS to /dev/sda
      "coreos-installer install /dev/sda -i /root/microshift.ign -s stable",
      # Exit rescue mode and boot into coreos
      "reboot"
    ]
  }
}
