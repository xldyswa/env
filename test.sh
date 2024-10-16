#!/bin/bash

# 设置变量
SEAPAPA_USER="seapapa"
SEAPAPA_PASSWORD="1"
CLIENT_USER="client"
CLIENT_PASSWORD="1234!@#$"
CLIENT_HOME="/home/${CLIENT_USER}"
local_ip=$(hostname -I | awk '{print $1}')
export_line="/mnt/shared ${local_ip}/24(rw,sync,no_subtree_check)"
easy_rsa="set_var EASYRSA_ALGO "ec""
easu_rsa1="set_var EASYRSA_DIGEST "sha512""

# 更新系统包
sudo apt-get update -y

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

#拉取work目录
scp -r ubuntu@101.32.223.170:/home/ubuntu/ssh/* /home/seapapa/.ssh
chmod 600 ~/.ssh/xld/xld
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/xld/xld
git clone git@github.com:vewe-richard/work.git

# 克隆sd-wan-env项目
cd work/system
git clone https://gitee.com/vewe-richard/sd-wan-env.git

# 配置Docker
sudo docker login --username=xldxx registry.cn-hangzhou.aliyuncs.com --password=xx123456
sudo docker pull registry.cn-hangzhou.aliyuncs.com/seapapa/ubuntu:24.04
sudo docker tag registry.cn-hangzhou.aliyuncs.com/seapapa/ubuntu:24.04 sd-wan/ubt_iptools:v2
sudo docker pull registry.cn-hangzhou.aliyuncs.com/seapapa/dhcpd
sudo docker tag registry.cn-hangzhou.aliyuncs.com/seapapa/dhcpd networkboot/dhcpd

# 下载和转换Ubuntu云镜像
cp /home/seapapa/prepare/qemu_img/* /home/seapapa/work/images/ubuntu/server
cd /home/seapapa/work/images/ubuntu/server
qemu-img convert -f qcow2 -O raw noble-server-cloudimg-amd64.img image.img

# 设置云镜像的root密码
sudo apt install libguestfs-tools -y
sudo virt-customize -a image.img --root-password password:1

# 配置NFS
cd ~
sudo mkdir -p /mnt/shared
sudo chown nobody:nogroup /mnt/shared
sudo chmod 777 /mnt/shared
sudo sh -c "echo \"$export_line\" >> /etc/exports"
sudo exportfs -a
sudo systemctl restart nfs-kernel-server

# 下载和解压Linux内核
#cp /home/seapapa/prepare/kernel/* /home/seapapa/work/kernel/source
#cd /home/seapapa/work/kernel/source/linux-6.10.2

#cp /boot/config-"$(uname -r)" .config

#make defconfig

#make -j$(nproc) 2>&1 | tee log

#sudo make modules_install -j$(nproc)

#sudo make headers_install

#sudo make install


# 克隆和编译QEMU
#cd /home/seapapa/work/kernel/smallbuild
#git clone https://github.com/qemu/qemu.git
#cd qemu
#git checkout v6.0.0
#./configure --target-list=riscv64-softmmu --disable-werror
#make

# 克隆和编译Buildroot
#cd /home/seapapa/work/kernel/smallbuild
#git clone https://github.com/buildroot/buildroot.git
#git clone git@gitlab.com:buildroot.org/buildroot.git
#cd buildroot/
#make qemu_riscv64_virt_defconfig
#make

# 安装gtags插件
mkdir -p ~/.vim/pack/plugins/start
cd ~/.vim/pack/plugins/start
git clone https://github.com/ivechan/gtags.vim.git

# 安装NERDTree插件
cd ~
wget http://www.vim.org/scripts/download_script.php?src_id=17123 -O nerdtree.zip
unzip nerdtree.zip
mkdir -p ~/.vim/{plugin,doc}
cp plugin/NERD_tree.vim ~/.vim/plugin/
cp doc/NERD_tree.txt ~/.vim/doc/
sudo rm -r nerdtree_plugin nerdtree.zip doc syntax plugin

