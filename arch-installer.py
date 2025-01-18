import os

def configure_system():
    """
    ضبط إعدادات النظام.
    """
    print("==== ضبط إعدادات النظام ====")
    os.system("genfstab -U / >> /etc/fstab")
    print("تم ضبط إعدادات النظام!")

def install_desktop_environment():
    """
    تركيب سطح المكتب.
    """
    desktop_environments = {
        "1": "gnome",
        "2": "kde",
        "3": "xfce",
        "4": "mate",
        "5": "cinnamon"
    }

    print("==== اختر سطح المكتب ====")
    for key, value in desktop_environments.items():
        print(f"{key}. {value}")

    choice = input("أدخل رقم سطح المكتب: ")
    selected_desktop = desktop_environments.get(choice)

    if selected_desktop:
        print(f"==== تركيب {selected_desktop} ====")
        os.system(f"pacman -S --noconfirm {selected_desktop}")
        print(f"تم تركيب {selected_desktop} بنجاح!")
    else:
        print("اختيار غير صحيح.")

def install_display_manager():
    """
    تركيب مدير العرض.
    """
    display_managers = {
        "1": "gdm",
        "2": "sddm",
        "3": "lightdm"
    }

    print("==== اختر مدير العرض ====")
    for key, value in display_managers.items():
        print(f"{key}. {value}")

    choice = input("أدخل رقم مدير العرض: ")
    selected_display_manager = display_managers.get(choice)

    if selected_display_manager:
        print(f"==== تركيب {selected_display_manager} ====")
        os.system(f"pacman -S --noconfirm {selected_display_manager}")
        os.system(f"systemctl enable {selected_display_manager}")
        print(f"تم تركيب {selected_display_manager} بنجاح!")
    else:
        print("اختيار غير صحيح.")

def create_user():
    """
    إنشاء مستخدم جديد.
    """
    username = input("أدخل اسم المستخدم: ")
    password = input("أدخل كلمة المرور: ")

    print("==== إنشاء مستخدم جديد ====")
    os.system(f"useradd -m {username}")
    os.system(f"echo '{username}:{password}' | chpasswd")
    print(f"تم إنشاء المستخدم {username} بنجاح!")

def main():
    """
    الدالة الرئيسية.
    """
    configure_system()
    install_desktop_environment()
    install_display_manager()
    create_user()

    print("==== تم إكمال تثبيت Arch Linux! ====")
    print("أعد تشغيل النظام لبدء استخدامه.")

if __name__ == "__main__":
    main()
