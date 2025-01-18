import os

def configure_system():
    """
    Configures system settings.
    """
    print("==== Configuring system settings ====")
    os.system("echo 'root:password' | chpasswd") # Change root password
    os.system("ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime") # Set timezone (example)
    os.system("hwclock --systohc")
    os.system("echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen")
    os.system("locale-gen")
    os.system("echo 'LANG=en_US.UTF-8' > /etc/locale.conf")
    os.system("echo 'KEYMAP=us' > /etc/vconsole.conf") # Assuming US keyboard layout
    os.system("echo 'archlinux' > /etc/hostname") # Set hostname
    os.system("echo '127.0.0.1   localhost' >> /etc/hosts")
    os.system("echo '::1         localhost' >> /etc/hosts")
    os.system("echo '127.0.1.1   archlinux.localdomain archlinux' >> /etc/hosts")
    print("System settings configured!")

def install_desktop_environment():
    """
    Installs a desktop environment (optional).
    """
    desktop_environments = {
        "1": "gnome",
        "2": "kde",
        "3": "xfce",
        "4": "mate",
        "5": "cinnamon"
    }

    print("==== Choose a desktop environment (optional) ====")
    for key, value in desktop_environments.items():
        print(f"{key}. {value}")

    choice = input("Enter the number of your choice (or press Enter to skip): ")
    selected_desktop = desktop_environments.get(choice)

    if selected_desktop:
        print(f"==== Installing {selected_desktop} ====")
        os.system(f"pacman -S --noconfirm {selected_desktop}")
        print(f"{selected_desktop} installed successfully!")
    else:
        print("Skipping desktop environment installation.")

def install_display_manager():
    """
    Installs a display manager (optional).
    """
    display_managers = {
        "1": "gdm",
        "2": "sddm",
        "3": "lightdm"
    }

    print("==== Choose a display manager (optional) ====")
    for key, value in display_managers.items():
        print(f"{key}. {value}")

    choice = input("Enter the number of your choice (or press Enter to skip): ")
    selected_display_manager = display_managers.get(choice)

    if selected_display_manager:
        print(f"==== Installing {selected_display_manager} ====")
        os.system(f"pacman -S --noconfirm {selected_display_manager}")
        os.system(f"systemctl enable {selected_display_manager}")
        print(f"{selected_display_manager} installed successfully!")
    else:
        print("Skipping display manager installation.")

def create_user():
    """
    Creates a new user.
    """
    username = input("Enter a username: ")
    password = input("Enter a password: ")

    print(f"==== Creating user {username} ====")
    os.system(f"useradd -m {username}")
    os.system(f"echo '{username}:{password}' | chpasswd")
    print(f"User {username} created successfully!")

def main():
    """
    Main function.
    """
    configure_system()
    install_desktop_environment()
    install_display_manager()
    create_user()

    print("==== Arch Linux installation completed! ====")
    print("Reboot the system to start using it.")

if __name__ == "__main__":
    main()
