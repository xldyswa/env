#!/bin/bash
# 更新系统包
sudo apt-get update -y

# 安装必要的软件包
sudo apt-get install -y \
    git net-tools python3 python3-pygments vim global python3-pip openssh-server qemu-system-x86 linux-headers-$(uname -r) golang docker.io bc binutils bison dwarves flex gcc git gnupg2 gzip unzip libelf-dev libncurses-dev libssl-dev make openssl perl-base rsync tar xz-utils build-essential libguestfs-tools nfs-kernel-server pkg-config ninja-build g++ libglib2.0-dev libpixman-1-dev openvpn easy-rsa

cd ~
mkdir prepare
cd prepare
mkdir qemu_img
cd qemu_img
wget https://mirror.sjtu.edu.cn/ubuntu-cloud-images/noble/current/noble-server-cloudimg-amd64.img
wget https://mirror.sjtu.edu.cn/ubuntu-cloud-images/noble/current/unpacked/noble-server-cloudimg-amd64-vmlinuz-generic
cd ..
mkdir kernel
cd kernel
wget https://mirrors.aliyun.com/linux-kernel/v6.x/linux-6.10.2.tar.xz
tar -xvf linux-6.10.2.tar.xz
sudo rm -r linux-6.10.2.tar.xz


