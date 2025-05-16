packer {
  required_plugins {
    qemu = {
      version = "~> 1.1.2"
      source  = "github.com/hashicorp/qemu"
    }
    ansible = {
      version = "~> 1.1.3"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

source "qemu" "main" {
  iso_url      = "https://releases.ubuntu.com/releases/24.04/ubuntu-24.04.2-live-server-amd64.iso"
  iso_checksum = "sha256:d6dab0c3a657988501b4bd76f1297c053df710e06e0c3aece60dead24f270b4d"

  output_directory = "output"
  format           = "raw"
  accelerator      = "kvm"

  disk_size = "20G"

  disk_image = false

  cpus   = 4
  memory = 8192

  ssh_username         = "ubuntu"
  ssh_private_key_file = "ssh/id_ed25519"
  ssh_timeout          = "1h"

  http_directory = "cloud-init"

  boot_command = [
    "c<wait>linux /casper/vmlinuz --- autoinstall ds='nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/'<enter><wait><wait><wait><wait>initrd /casper/initrd<wait><wait><enter><wait>boot<enter>",
  ]
  shutdown_command = "sudo shutdown -P now"
}

build {
  sources = [
    "source.qemu.main"
  ]

  provisioner "ansible" {
    playbook_file = "../playbooks/playbooks/main.yml"
  }

  provisioner "shell" {
    inline = [
      "sudo cloud-init clean"
    ]
  }
}
