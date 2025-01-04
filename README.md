# Linux VM

The scripts in this repository create a VM image containing a Debian 12
(bookworm) system. It can be used as a base for a showcase, a VM used in a
workshow, etc.

The scripts should be run on a Debian system. Furthermore, `create-vm`
depends on the _debootstrap_ package, and `image-to-ova` depends on the
_uuid-runtime_ and _qemu-utils_ packages.

Type `./create-vm --help` or `./image-to-ova --help` to display a list of
all available options.

## Building the Image

The command

```sh
./create-vm image.img
```

creates a raw VM image file `image.img`. It uses either `sudo` or `su` to
run as _root_, and may prompt for the _root_ password.

Creating the image file on a RAM disk speeds up the process, but note that
about 6 GB of free space are needed in the directory where the image file is
created.

## Testing the Image

The following command can be used to test the generated image with qemu:

```sh
qemu-system-x86_64 \
    -cpu kvm64 \
    -machine accel=kvm \
    -smp 4 \
    -m 8G \
    -drive file=image.img,if=virtio,media=disk,format=raw \
    -nic user,model=e1000
```

## Converting the Image to a Virtual Appliance

The command

```sh
./image-to-ova image.img VM
```

creates a virtual appliance `VM.ova` (and other files). The appliance is
optimized for VirtualBox, but may work in other virtualization software.

Note that `create-vm` installs the VirtualBox guest utilities into the
image.

If the `VBoxManage` utility is installed, `create-vm` uses it internally to
convert the image file, otherwise it uses the `qemu-img` command.

## The Virtual Machine

When the virtual machine is started for the first time (or after the
`cleanup-shutdown` command has been used; see below), a dialog is shown
during bootup to select the keyboard layout and variant.

The password of the _root_ user is empty. An unprivileged user account with
the username _user_ exists in the virtual machine; its password is empty as
well.

The command `cleanup-shutdown` (to be run as _root_) can be used to clean up
the virtual machine after further setup (e.g., after installing additional
software). It removes log files, caches, and history files, resets the
desktop environment configuration, discards unused disk blocks, and shuts
down the virtual machine.

Discarding unused disk blocks decreases the size of the virtual image file.
It may take several minutes.
