### Variables

variable "fdos_version" {
  type        = string
  description = "FreeDOS Version"
}

variable "iso_file" {
  type        = string
  description = "FreeDOS ISO Filename"
}

variable "iso_checksum" {
  type        = string
  description = "FreeDOS ISO Checksum"
}

### Builders

source "qemu" "freedos" {
  boot_command = [
    # Syslinux Menu
    "L",                                 # Use FreeDOS in Live Environment Mode
    "<wait10>",

    # DOS prompt
    "fdisk /auto /reboot<enter>",
    "<wait10>",

    # Syslinux Menu
    "I",                                 # Install to harddisk
    "<wait10>",

    # FreeDOS Installator
    "<enter><wait>",                     # What is your preferred language? English.
    "<enter><wait>",                     # Do you want to proceed? Yes.
    "y<enter><wait>",                    # Do you want to format? Yes.
    "<enter><wait10>",                   # Press a key
    "<enter><wait>",                     # Please select your keyboard leyaout. US English (Default)
    #"<enter><wait>",                     # What FreeDOS packages do you want to install? Full installation incl. applications and games.
    "<up><up><enter><wait>",             # What FreeDOS packages do you want to install? Plain DOS system
    "y<enter><wait30>",                  # Do you want to install now? Yes.
    "y<enter><wait10>",                  # Do you want to reboot now? Yes

    # Bootloader
    "h<wait5>",                          # Boot from system harddisk

    # FreeDOS Boot Loader
    "<enter><wait10>",                   # Select ???

    # FDIMPLES
    "fdimples<enter>",
    "<down><down><enter>",               # Select FreeDOS Base
    "<down><down><down><down><enter>",   # Select Editors
    "<down><down><enter>",               # Select Networking
    "<down><down><enter>",               # Select Unix Like Tools
    "<down><enter>",                     # Select Utilities
    "<tab><tab><tab><enter>",            # Select "OK"
    "<wait90>",

    # DOS prompt
    "b:<enter><wait><enter><wait>",
    "unzip rmenu.zip -d c:\\net\\rmenu<enter><wait>",
    "cd src<enter>",
    "install.bat /shutdown<enter>",       # Install FreeDOS2cloud scripts
  ]

  boot_wait         = "10s"
  disk_cache        = "unsafe"
  disk_interface    = "virtio-scsi"
  disk_size         = "768M"
  format            = "qcow2"

  cdrom_interface   = "ide"
  floppy_dirs       = ["src", "build/source/rmenu.zip"]
  iso_checksum      = "${var.iso_checksum}"

  iso_urls = [
    "file://${var.iso_file}"
## ZIP archives can't be directly used as they contain more files, see:
# error downloading ISO: [expected a single file: /tmp/getter4051298070/archive]
#    "https://www.ibiblio.org/pub/micro/pc-stuff/freedos/files/distributions/${var.fdos_version}/${var.preview_location}/FD13-LiveCD.zip"
  ]

  output_directory = "build/image"

  qemuargs = [
    ["-m", "16"],
    ["-boot", "d"],
  ]

  ssh_timeout      = "30m"
  ssh_username     = "root"
  communicator     = "none"
  vm_name          = "freedos-${var.fdos_version}.qcow2"
}

build {
  sources = [
    "source.qemu.freedos"
  ]
}
