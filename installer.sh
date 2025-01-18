#!/bin/bash

# اسم ملف بايثون الذي سيتم تشغيله
python_script="arch-installer.py"

# مسار بايثون (بعد التثبيت)
python_bin="/usr/bin/python"

# دالة لفحص الاتصال بالإنترنت
check_internet() {
    ping -c 1 google.com &> /dev/null
    if [ $? -eq 0 ]; then
        echo "==== متصل بالإنترنت ===="
        return 0
    else
        echo "==== غير متصل بالإنترنت! تأكد من الاتصال وحاول مرة أخرى. ===="
        return 1
    fi
}

# دالة لتحميل بايثون
install_python() {
    echo "==== تحميل بايثون ===="
    pacstrap /mnt base python
    if [ $? -eq 0 ]; then
        echo "==== تم تحميل بايثون بنجاح ===="
    else
        echo "==== فشل تحميل بايثون! تحقق من اتصالك بالإنترنت وحاول مرة أخرى. ===="
        exit 1
    fi
}

# دالة لتشغيل ملف بايثون
run_python_script() {
    echo "==== تشغيل $python_script ===="
    arch-chroot /mnt "$python_bin" "/root/$python_script"
    if [ $? -eq 0 ]; then
        echo "==== تم تشغيل $python_script بنجاح ===="
    else
        echo "==== فشل تشغيل $python_script! تحقق من الكود وحاول مرة أخرى. ===="
        exit 1
    fi
}

# الدالة الرئيسية
main() {
    check_internet || exit 1
    # تركيب النظام الأساسي قبل تثبيت بايثون
    echo "==== تركيب النظام الأساسي ===="
    pacstrap /mnt base linux linux-firmware
    echo "تم تركيب النظام الأساسي بنجاح!"
    # نسخ ملف بايثون إلى  mnt/root
    echo "==== نسخ $python_script إلى /mnt/root/ ===="
    cp "$python_script" /mnt/root/
    install_python
    run_python_script
}

main
