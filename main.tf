terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "2.9.13"
    }
  }
}

provider "proxmox" {
  # url is the hostname (FQDN if you have one) for the proxmox host you'd like to connect to to issue the commands. my proxmox host is 'pve'. Add /api2/json at the end for the API
  pm_api_url = "https://10.10.0.101:8006/api2/json"

  # api token id is in the form of: <username>@pam!<tokenId>
  pm_api_token_id = "hadhemi@pam!wannaci"

  # this is the full secret wrapped in quotes. don't worry, I've already deleted this from my proxmox cluster by the time you read this post
  pm_api_token_secret = "ae43c83c-61e2-4342-b0d9-2b67670ccc9d"

  # leave tls_insecure set to true unless you have your proxmox SSL certificate situation fully sorted out (if you do, you will know)
  pm_tls_insecure = true
}

# resource is formatted to be "[type]" "[entity_name]" so in this case
# we are looking to create a proxmox_vm_qemu entity named kube-master
resource "proxmox_vm_qemu" "kube-master" {
  count = 3 # just want 1 for now, set to 0 and apply to destroy VM
  name = "kube-master-0${count.index + 1}" #count.index starts at 0, so + 1 means this VM will be named test-vm-1 in proxmox

  # this now reaches out to the vars file. I could've also used this var above in the pm_api_url setting but wanted to spell it out up there. target_node is different than api_url. target_node is which node hosts the template and thus also which node will host the new VM. it can be different than the host you use to communicate with the API. the variable contains the contents "prox-1u"
  target_node = "pve"

  # another variable with contents "ubuntu-2004-cloudinit-template"
  clone = "ubuntu-2004-cloudinit-template"

  # basic VM settings here. agent refers to guest agent
  agent = 1
  os_type = "cloud-init"
  cores = 2
  sockets = 1
  cpu = "host"
  memory = 10240
  scsihw = "virtio-scsi-pci"
  bootdisk = "scsi0"
  disk {
    slot = 0
    # set disk size here. leave it small for testing because expanding the disk takes time.
    size = "50G"
    type = "scsi"
    storage = "local-lvm"
    #iothread = 1
  }
  
  # if you want two NICs, just copy this whole network section and duplicate it
  network {
    model = "virtio"
    bridge = "vmbr0"
  }
  # not sure exactly what this is for. presumably something about MAC addresses and ignore network changes during the life of the VM
  lifecycle {
    ignore_changes = [
      network,
    ]
  }
  
  # in this case, since we are only adding a single VM, the IP will
  # be 10.10.0.40 since count.index starts at 0. this is how you can create
  ipconfig0 = "ip=10.10.0.4${count.index + 1}/16,gw=10.10.0.254"
  
  # sshkeys set using variables. the variable contains the text of the key.
  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
}
# we are looking to create a proxmox_vm_qemu entity named kube-agent
resource "proxmox_vm_qemu" "kube-agent" {
  count = 2 # just want 1 for now, set to 0 and apply to destroy VM
  name = "kube-agent-0${count.index + 1}" #count.index starts at 0, so + 1 means this VM will be named test-vm-1 in proxmox

  # this now reaches out to the vars file. I could've also used this var above in the pm_api_url setting but wanted to spell it out up there. target_node is different than api_url. target_node is which node hosts the template and thus also which node will host the new VM. it can be different than the host you use to communicate with the API. the variable contains the contents "prox-1u"
  target_node = "pve"

  # another variable with contents "ubuntu-2004-cloudinit-template"
  clone = "ubuntu-2004-cloudinit-template"

  # basic VM settings here. agent refers to guest agent
  agent = 1
  os_type = "cloud-init"
  cores = 2
  sockets = 1
  cpu = "host"
  memory = 10240
  scsihw = "virtio-scsi-pci"
  bootdisk = "scsi0"
  disk {
    slot = 0
    # set disk size here. leave it small for testing because expanding the disk takes time.
    size = "50G"
    type = "scsi"
    storage = "local-lvm"
    #iothread = 1
  }
  
  # if you want two NICs, just copy this whole network section and duplicate it
  network {
    model = "virtio"
    bridge = "vmbr0"
  }
  # not sure exactly what this is for. presumably something about MAC addresses and ignore network changes during the life of the VM
  lifecycle {
    ignore_changes = [
      network,
    ]
  }
  
  # the ${count.index + 1} thing appends text to the end of the ip address
  # in this case, since we are only adding a single VM, the IP will
  # be 10.10.0.50 since count.index starts at 0. this is how you can create
  # multiple VMs and have an IP assigned to each (.51, .52, .53, etc.)
  ipconfig0 = "ip=10.10.0.5${count.index + 1}/16,gw=10.10.0.254"
  
  # sshkeys set using variables. the variable contains the text of the key.
  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
}
# we are looking to create a proxmox_vm_qemu entity named jenkins
resource "proxmox_vm_qemu" "jenkins" {
  count = 1 # just want 1 for now, set to 0 and apply to destroy VM
  name = "jenkins" #count.index starts at 0, so + 1 means this VM will be named test-vm-1 in proxmox

  # this now reaches out to the vars file. I could've also used this var above in the pm_api_url setting but wanted to spell it out up there. target_node is different than api_url. target_node is which node hosts the template and thus also which node will host the new VM. it can be different than the host you use to communicate with the API. the variable contains the contents "prox-1u"
  target_node = "pve"

  # another variable with contents "ubuntu-2004-cloudinit-template"
  clone = "ubuntu-2004-cloudinit-template"

  # basic VM settings here. agent refers to guest agent
  agent = 1
  os_type = "cloud-init"
  cores = 2
  sockets = 1
  cpu = "host"
  memory = 8192
  scsihw = "virtio-scsi-pci"
  bootdisk = "scsi0"
  disk {
    slot = 0
    # set disk size here. leave it small for testing because expanding the disk takes time.
    size = "50G"
    type = "scsi"
    storage = "local-lvm"
    #iothread = 1
  }
  
  # if you want two NICs, just copy this whole network section and duplicate it
  network {
    model = "virtio"
    bridge = "vmbr0"
  }
  # not sure exactly what this is for. presumably something about MAC addresses and ignore network changes during the life of the VM
  lifecycle {
    ignore_changes = [
      network,
    ]
  }
  
  # in this case, since we are only adding a single VM, the IP will
  # be 10.10.0.60 since count.index starts at 0. this is how you can create
  ipconfig0 = "ip=10.10.0.60/16,gw=10.10.0.254"
  
  # sshkeys set using variables. the variable contains the text of the key.
  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
}
# we are looking to create a proxmox_vm_qemu entity named Administation
resource "proxmox_vm_qemu" "Administation" {
  count = 1 # just want 1 for now, set to 0 and apply to destroy VM
  name = "Administation" #count.index starts at 0, so + 1 means this VM will be named test-vm-1 in proxmox

  # this now reaches out to the vars file. I could've also used this var above in the pm_api_url setting but wanted to spell it out up there. target_node is different than api_url. target_node is which node hosts the template and thus also which node will host the new VM. it can be different than the host you use to communicate with the API. the variable contains the contents "prox-1u"
  target_node = "pve"

  # another variable with contents "ubuntu-2004-cloudinit-template"
  clone = "ubuntu-2004-cloudinit-template"

  # basic VM settings here. agent refers to guest agent
  agent = 1
  os_type = "cloud-init"
  cores = 2
  sockets = 1
  cpu = "host"
  memory = 4096
  scsihw = "virtio-scsi-pci"
  bootdisk = "scsi0"
  disk {
    slot = 0
    # set disk size here. leave it small for testing because expanding the disk takes time.
    size = "20G"
    type = "scsi"
    storage = "local-lvm"
    #iothread = 1
  }
  
  # if you want two NICs, just copy this whole network section and duplicate it
  network {
    model = "virtio"
    bridge = "vmbr0"
  }
  # not sure exactly what this is for. presumably something about MAC addresses and ignore network changes during the life of the VM
  lifecycle {
    ignore_changes = [
      network,
    ]
  }
  
  # in this case, since we are only adding a single VM, the IP will
  # be 10.10.0.70 since count.index starts at 0. this is how you can create
  ipconfig0 = "ip=10.10.0.70/16,gw=10.10.0.254"
  
  # sshkeys set using variables. the variable contains the text of the key.
  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
}
