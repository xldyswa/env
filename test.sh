#!/bin/bash

# 设置变量
SEAPAPA_USER="seapapa"
SEAPAPA_PASSWORD="1"
CLIENT_USER="client"
CLIENT_PASSWORD="1234!@#$"
CLIENT_HOME="/home/${CLIENT_USER}"
local_ip=$(hostname -I | awk '{print $1}')
export_line="/mnt/shared ${local_ip}/24(rw,sync,no_subtree_check)"

# 更新系统包
sudo apt-get update -y

# 安装必要的软件包
sudo apt-get install -y \
    git net-tools python3 python3-pygments vim global python3-pip openssh-server \
    qemu-system-x86 linux-headers-$(uname -r) golang docker.io bc binutils bison \
    dwarves flex gcc git gnupg2 gzip unzip libelf-dev libncurses-dev libssl-dev \
    make openssl perl-base rsync tar xz-utils build-essential libguestfs-tools \
    nfs-kernel-server pkg-config ninja-build g++ libglib2.0-dev libpixman-1-dev

# 创建客户端用户
if id "${CLIENT_USER}" &>/dev/null; then
    echo "用户 ${CLIENT_USER} 已经存在。"
else
    sudo useradd -m -s /bin/bash "${CLIENT_USER}"
    echo "${CLIENT_USER}:${CLIENT_PASSWORD}" | sudo chpasswd
    echo "用户 ${CLIENT_USER} 创建完成。"
fi

# 设置用户主目录权限
sudo chmod 700 "${CLIENT_HOME}"
echo "已设置 ${CLIENT_USER} 仅具有其主目录的读写权限。"

# 克隆sd-wan-env项目
git clone https://gitee.com/vewe-richard/sd-wan-env.git

# 配置Docker
sudo docker login --username=xldxx registry.cn-hangzhou.aliyuncs.com --password=xx123456
sudo docker pull registry.cn-hangzhou.aliyuncs.com/seapapa/ubuntu:24.04
sudo docker tag registry.cn-hangzhou.aliyuncs.com/seapapa/ubuntu:24.04 sd-wan/ubt_iptools:v2
sudo docker pull registry.cn-hangzhou.aliyuncs.com/seapapa/dhcpd
sudo docker tag registry.cn-hangzhou.aliyuncs.com/seapapa/dhcpd networkboot/dhcpd

# 下载和转换Ubuntu云镜像
wget https://mirror.sjtu.edu.cn/ubuntu-cloud-images/noble/current/noble-server-cloudimg-amd64.img
wget https://mirror.sjtu.edu.cn/ubuntu-cloud-images/noble/current/unpacked/noble-server-cloudimg-amd64-vmlinuz-generic
qemu-img convert -f qcow2 -O raw noble-server-cloudimg-amd64.img image.img

# 设置云镜像的root密码
sudo apt install libguestfs-tools -y
sudo virt-customize -a image.img --root-password password:1
sudo rm -r noble-server-cloudimg-amd64.img noble-server-cloudimg-amd64-vmlinuz-generic

# 配置NFS
sudo mkdir -p /mnt/shared
sudo chown nobody:nogroup /mnt/shared
sudo chmod 777 /mnt/shared
sudo sh -c "echo \"$export_line\" >> /etc/exports"
sudo exportfs -a
sudo systemctl restart nfs-kernel-server

# 下载和解压Linux内核
wget https://mirrors.aliyun.com/linux-kernel/v6.x/linux-6.9.7.tar.xz
tar -xvf linux-6.9.7.tar.xz
sudo rm -r linux-6.9.7.tar.xz

# 克隆和编译QEMU
git clone https://github.com/qemu/qemu.git
cd qemu
git checkout v6.0.0
./configure --target-list=riscv64-softmmu
make

# 克隆和编译Buildroot
cd ~
git clone https://github.com/buildroot/buildroot.git
cd buildroot/
make qemu_riscv64_virt_defconfig
make

# 安装gtags插件
mkdir -p /root/.vim/pack/plugins/start
cd /root/.vim/pack/plugins/start
git clone https://github.com/ivechan/gtags.vim.git

# 安装NERDTree插件
wget http://www.vim.org/scripts/download_script.php?src_id=17123 -O nerdtree.zip
unzip nerdtree.zip
mkdir -p ~/.vim/{plugin,doc}
cp plugin/NERD_tree.vim ~/.vim/plugin/
cp doc/NERD_tree.txt ~/.vim/doc/
sudo rm -r nerdtree_plugin nerdtree.zip doc syntax plugin
