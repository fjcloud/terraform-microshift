# -[Provider]--------------------------------------------------------------
provider "libvirt" {
  uri = "qemu:///system"
}

# -[Variables]-------------------------------------------------------------
variable "ignite_file" {
  type    = string
}

# -[Resources]-------------------------------------------------------------
resource "libvirt_volume" "coreos-disk" {
  name   = "microshift"
  source = "/tmp/fedora-coreos-36.20220820.3.0-qemu.x86_64.qcow2"
}

resource "libvirt_ignition" "ignition" {
  name = "ignition"
  content = base64decode(var.ignite_file)
}

# Create the virtual machines
resource "libvirt_domain" "coreos-machine" {
  name   = "microshift"
  vcpu   = "2"
  memory = "2048"

  ## Use qemu-agent in conjunction with the container
  qemu_agent = true
  coreos_ignition = libvirt_ignition.ignition.id

  disk {
    volume_id = libvirt_volume.coreos-disk.id
  }

  console {
    type = "pty"
    target_port = "0"
  }

  network_interface {
    network_name = "default"
    wait_for_lease = true
  }
}

# -[Output]-------------------------------------------------------------
output "microshift_ip" {
  value = tostring(libvirt_domain.coreos-machine.network_interface.0.addresses.0)
}
