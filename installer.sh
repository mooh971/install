#!/bin/bash

# Name of the Python script to be executed
python_script="arch-installer.py"

# Path to the Python binary (after installation)
python_bin="/usr/bin/python"

# Function to check internet connectivity
check_internet() {
    ping -c 1 google.com &> /dev/null
    if [ $? -eq 0 ]; then
        echo "==== Connected to the internet ===="
        return 0
    else:
        echo "==== Not connected to the internet! Please check your connection and try again. ===="
        return 1
    fi
}

# Function to display a list of available disks and let the user select one
select_disk() {
    echo "==== Available disks ===="
    lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT | grep -v "loop"

    read -r -p "Enter the name of the disk you want to use (e.g., sda): " selected_disk

    # Validate the disk name
    if lsblk /dev/"$selected_disk" &> /dev/null; then
        echo "==== Selected disk: /dev/$selected_disk ===="
        target_disk="/dev/$selected_disk"
    else:
        echo "==== Error: Disk /dev/$selected_disk not found ===="
        exit 1
    fi
}

# Function to check free disk space before partitioning
check_disk_space() {
    # Calculate required space (in MB) - Adjust these values if needed
    # Considering 1 MiB = 1048576 bytes and 1 MB = 1000000 bytes
    # We use a conservative estimate to ensure enough space
    boot_size_mb=$((1024 * 1048576 / 1000000)) # 1 GiB in MB considering binary to decimal conversion
    required_root_size_mb=25000 # Minimum 25 GB for root
    total_required_mb=$((boot_size_mb + required_root_size_mb))

    # Get disk size (in MB)
    disk_size_mb=$(lsblk -b "$target_disk" -o SIZE -n | awk '{print int($1/1000000)}') # Convert bytes to MB

    echo "==== Checking available disk space ===="
    echo "==== Required space: $total_required_mb MB"
    echo "==== Available space on $target_disk: $disk_size_mb MB"

    if (( disk_size_mb >= total_required_mb )); then
        echo "==== Sufficient disk space available ===="
    else:
        echo "==== Error: Not enough free disk space on $target_disk ===="
        echo "==== You need at least $total_required_mb MB, but only $disk_size_mb MB is available. ===="
        exit 1
    fi
}

# Function to wipe out existing partitions and partition the selected disk
partition_disk() {
    echo "==== Wiping out existing partitions on $target_disk ===="
    sgdisk --zap-all "$target_disk"

    echo "==== Partitioning disk $target_disk ===="
    # Create a GPT partition table
    parted -s "$target_disk" mklabel gpt
    # Create a 1 GiB FAT32 partition for EFI system partition (ESP)
    parted -s "$target_disk" mkpart primary fat32 1MiB 1025MiB
    # Set the ESP flag on the first partition
    parted -s "$target_disk" set 1 esp on
    # Create an ext4 partition for the rest of the disk
    parted -s "$target_disk" mkpart primary ext4 1025MiB 100%

    # Wait for the partitions to appear
    udevadm settle
    echo "==== Disk partitioned successfully ===="
}

# Function to format the partitions
format_partitions() {
    echo "==== Formatting partitions ===="
    mkfs.fat -F 32 "${target_disk}1"  # Format boot partition as FAT32
    mkfs.ext4 "${target_disk}2"  # Format root partition as ext4
    echo "==== Partitions formatted successfully ===="
}

# Function to mount the partitions
mount_partitions() {
    echo "==== Mounting partitions ===="
    mount "${target_disk}2" /mnt  # Mount root partition
    mkdir -p /mnt/boot
    mount "${target_disk}1" /mnt/boot  # Mount boot partition
    echo "==== Partitions mounted successfully ===="
}

# Function to install the base system and Python
install_base() {
    echo "==== Installing base system and Python ===="
    pacstrap /mnt base linux linux-firmware python
    if [ $? -eq 0 ]; then
        echo "==== Base system and Python installed successfully ===="
    else:
        echo "==== Failed to install base system! Check your internet connection and try again. ===="
        exit 1
    fi
}

# Function to run the Python script
run_python_script() {
    echo "==== Running $python_script ===="
    arch-chroot /mnt "$python_bin" "/root/$python_script"
    if [ $? -eq 0 ]; then
        echo "==== $python_script executed successfully ===="
    else:
        echo "==== Failed to execute $python_script! Check the code and try again. ===="
        exit 1
    fi
}

# Main function
main() {
    check_internet || exit 1

    select_disk
    check_disk_space

    # Important warning!
    echo "==== WARNING: This will repartition the disk $target_disk ===="
    echo "==== Make sure you have backed up all your important data ===="
    read -r -p "Are you sure you want to proceed? (y/n): " response
    if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "==== Operation cancelled ===="
        exit 0
    fi

    partition_disk
    format_partitions
    mount_partitions

    # Copy the Python script to /mnt/root
    echo "==== Copying $python_script to /mnt/root/ ===="
    cp "$python_script" /mnt/root/

    install_base
    run_python_script
}

main
