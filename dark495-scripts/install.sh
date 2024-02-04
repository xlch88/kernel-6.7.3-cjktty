cla="[0m[32m[1m"
clb="[0m[36m[1m"
clc="[0m[31m[1m"
cld="[0m[35m[1m"
cle="[0m[33m[1m"
clf="[0m[37m[1m"
clcc="[0m"

if [ -d "/lib/modules/6.7.3-dark495-cjktty+" ]; then
	if [ ! -z "$(uname -r | grep '6.7.3-dark495-cjktty+')" ]; then
		echo "${clb}看上去你已经安装过了 :)"
		echo "${cla}你可以在物理屏幕的终端上输入 ${clf}'${clb}curl s.qwq.pink/cntest|sh${clf}' ${cla}来测试效果。${clcc}"
		exit 0
	else
		echo "${clb}It looks like you already have it installed."
		echo "${clb}But you didn't select that kernel on boot."
		echo "${cla}Reboot and select ${clf}'${clb}dark495-cjktty${clf}'${cla} to ${cle}enjoy.${clcc}"
		exit 1
	fi
fi

rm -rf /tmp/cjktty-kernel
mkdir -p /tmp/cjktty-kernel || exit 99
cd /tmp/cjktty-kernel || exit 100

echo "${clb}Downloading kernel file ...${clcc}"
curl -L -A "npm/8.9.64 node/89.64" -o cjktty673-1.0.0.tgz --connect-timeout 10 -m 600 --retry 10 --progress-bar "https://registry.npmmirror.com/cjktty673/-/cjktty673-1.0.0.tgz" || exit 101
echo "${clb}Unzip ...${clcc}"
tar -xvf cjktty673-1.0.0.tgz || exit 102

cd /tmp/cjktty-kernel/package

echo "${clb}Install Kernel Package ...${clcc}"
if [ -f /usr/bin/rpm ]; then
	rpm -ivh *.rpm || exit 103
elif [ -f /usr/bin/dpkg ]; then
	dpkg -i *.deb || exit 104
fi

echo "${clb}Change GRUB Timeout & Style ...${clcc}"
sed -i 's/^GRUB_TIMEOUT_STYLE/#GRUB_TIMEOUT_STYLE/' /etc/default/grub
sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=5/' /etc/default/grub

if [ -f /usr/bin/rpm ]; then
	grub2-mkconfig -o /boot/grub/grub.cfg
elif [ -f /usr/bin/dpkg ]; then
	update-grub
fi

echo "${cla}Done !!! Reboot and select ${clf}'${clb}dark495-cjktty${clf}'${cla} to ${cle}enjoy.${clcc}"
echo "${cld}After you reboot and correctly select the kernel, You can test the display effect using ${clf}'${clb}curl s.qwq.pink/cntest|sh${clf}'${clcc}"
