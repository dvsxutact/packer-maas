url --mirrorlist="http://mirrorlist.centos.org/?release=7&arch=x86_64&repo=os"
poweroff
firewall --enabled --service=ssh
firstboot --disable
ignoredisk --only-use=vda
lang en_US.UTF-8
keyboard us
network --device eth0 --bootproto=dhcp
firewall --enabled --service=ssh
selinux --enforcing
timezone UTC --isUtc
bootloader --location=mbr --driveorder="vda" --timeout=1
rootpw --plaintext password

repo --name="Updates" --mirrorlist="http://mirrorlist.centos.org/?release=7&arch=x86_64&repo=updates"
repo --name="Extras" --mirrorlist="http://mirrorlist.centos.org/?release=7&arch=x86_64&repo=extras"
repo --name="cloud-init" --baseurl="http://copr-be.cloud.fedoraproject.org/results/@cloud-init/el-stable/epel-7-x86_64"

zerombr
clearpart --all --initlabel
part / --size=1 --grow --asprimary --fstype=ext4

%post --erroronfail
# workaround anaconda requirements and clear root password
passwd -d root
passwd -l root

# Clean up install config not applicable to deployed environments.
for f in resolv.conf fstab; do
    rm -f /etc/$f
    touch /etc/$f
    chown root:root /etc/$f
    chmod 644 /etc/$f
done

rm -f /etc/sysconfig/network-scripts/ifcfg-[^lo]*

yum clean all
%end

%packages
@core
bash-completion
cloud-init-el-release
cloud-init
# cloud-init only requires python-oauthlib with MAAS. As such upstream
# has removed python-oauthlib from cloud-init's deps.
python2-oauthlib
cloud-utils-growpart
rsync
tar
yum-utils
# bridge-utils is required by cloud-init to configure networking. Without it
# installed cloud-init will try to install it itself which will not work in
# isolated environments.
bridge-utils
# Tools needed to allow custom storage to be deployed without acessing the
# Internet.
grub2-efi-x64
shim-x64
# Older versions of Curtin do not support secure boot and setup grub by
# generating grubx64.efi with grub2-efi-x64-modules.
grub2-efi-x64-modules
efibootmgr
dosfstools
lvm2
mdadm
device-mapper-multipath
iscsi-initiator-utils
-plymouth
# Remove ALSA firmware
-a*-firmware
# Remove Intel wireless firmware
-i*-firmware
# Include nano
nano
%end
