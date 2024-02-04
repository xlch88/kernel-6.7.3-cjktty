# kernel-6.7.3-cjktty
这里有已经构建好了的打了cjktty中文补丁的6.7.3内核源码和成品。

如果要成品，请见 [Releases](https://github.com/xlch88/kernel-6.7.3-cjktty/releases)

考虑到需要中文补丁的大部分都是中国用户，所以该文档使用中文编写（反正我英语也烂的一批）。

Kernel官网：https://www.kernel.org/  
补丁链接：https://github.com/zhmars/cjktty-patches

# 自己动手
好的，如果你愿意自己尝试编译一个内核或者像我一样想掌握一门新的技能，那么就请往下看。

编译内核其实和编译一般的linux软件没什么太大的区别，无非就是：**配置开发环境、下源码、设置一些选项、make、make install**

补丁(patch文件)的原理呢，是将 未改动的内核源码 和 在内核源码的基础上继续写上中文支持的源码 进行比较，将比较后的差异记录下来就是补丁文件了。

这里，我们使用CentOS7来编译。为什么选这个呢，因为我的工作中用到的最多的就是这个系统，虽然现在看上去它有点旧，而且马上就要停止维护了(此文写于2024-02-04)，但是，能跑。

然后，我懒得放图片或者更多的注释什么了，基本上都是简单粗暴的直接上指令。如果有问题你可以提个issues，我看兴趣回答。

## 安装各种依赖
就直接无脑装就行了，这一步应该出不了错
```shell
yum groupinstall "Development Tools" -y
yum install openssl-devel -y
yum install rpm-build redhat-rpm-config asciidoc hmaccalc perl-ExtUtils-Embed pesign xmlto -y
yum install audit-libs-devel binutils-devel elfutils-devel elfutils-libelf-devel -y
yum install ncurses-devel newt-devel numactl-devel pciutils-devel python-devel zlib-devel -y
yum install patch -y
```

接下来，要解决CentOS7各种版本太旧的问题，比如下面这个，是安装gcc7版本，系统自带的4版本太旧了根本无法完成编译。
```shell
yum install centos-release-scl -y
yum install devtoolset-7-gcc* -y

scl enable devtoolset-7 bash
# 这里还是说一下，执行完上面这一句以后，会打开一个版本7的bash，但这是临时的，你按Ctrl+D退出就没了
# 如果要永久，你需要执行这个
echo ". /opt/rh/devtoolset-7/enable" >>/etc/profile
```

解决git版本太旧的问题
```shell
git --version
yum remove git
yum remove git-*
yum install https://packages.endpointdev.com/rhel/7/os/x86_64/endpoint-repo.x86_64.rpm
yum install git
```

解决rpm版本太旧的问题
```shell
rpm -Uvh https://cbs.centos.org/kojifiles/packages/rpm/4.13.0.2/1.el7.c8/x86_64/rpm-4.13.0.2-1.el7.c8.x86_64.rpm \
https://cbs.centos.org/kojifiles/packages/rpm/4.13.0.2/1.el7.c8/x86_64/rpm-plugin-selinux-4.13.0.2-1.el7.c8.x86_64.rpm \
https://cbs.centos.org/kojifiles/packages/rpm/4.13.0.2/1.el7.c8/x86_64/rpm-plugin-ima-4.13.0.2-1.el7.c8.x86_64.rpm \
https://cbs.centos.org/kojifiles/packages/rpm/4.13.0.2/1.el7.c8/x86_64/rpm-plugin-syslog-4.13.0.2-1.el7.c8.x86_64.rpm \
https://cbs.centos.org/kojifiles/packages/rpm/4.13.0.2/1.el7.c8/x86_64/rpm-plugin-systemd-inhibit-4.13.0.2-1.el7.c8.x86_64.rpm \
https://cbs.centos.org/kojifiles/packages/rpm/4.13.0.2/1.el7.c8/x86_64/rpm-libs-4.13.0.2-1.el7.c8.x86_64.rpm \
https://cbs.centos.org/kojifiles/packages/rpm/4.13.0.2/1.el7.c8/x86_64/python2-rpm-4.13.0.2-1.el7.c8.x86_64.rpm \
https://cbs.centos.org/kojifiles/packages/rpm/4.13.0.2/1.el7.c8/x86_64/rpm-devel-4.13.0.2-1.el7.c8.x86_64.rpm \
https://cbs.centos.org/kojifiles/packages/rpm/4.13.0.2/1.el7.c8/x86_64/rpm-build-libs-4.13.0.2-1.el7.c8.x86_64.rpm \
https://cbs.centos.org/kojifiles/packages/rpm/4.13.0.2/1.el7.c8/x86_64/rpm-build-4.13.0.2-1.el7.c8.x86_64.rpm \
https://cbs.centos.org/kojifiles/packages/rpm/4.13.0.2/1.el7.c8/x86_64/rpm-sign-4.13.0.2-1.el7.c8.x86_64.rpm
```

## 真正开搞
创目录，下源码，解压，打补丁
```shell
mkdir test
cd test

wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.7.3.tar.xz
wget https://raw.githubusercontent.com/zhmars/cjktty-patches/master/v6.x/cjktty-6.7.patch

tar -xvf linux-6.7.3.tar.xz
cd linux-6.7.3

patch -Np1 <../cjktty-6.7.patch
```

将系统自带的配置文件照抄一份到我们这里，在此基础上进行需要的修改会省很多事。
```shell
cp -v /boot/config-$(uname -r) .config
```

进入图形化配置界面，
```shell
make menuconfig
```

那么根据我查到的资料，是需要改动这三个部分
```
1. Cryptographic API -> Certificates for signature checking -> Provide system-wide ring of trusted keys，将这一行里的内容清空（编辑下面...X.509...行，删除所有内容）。或者编辑.config文件设置CONFIG_SYSTEM_TRUSTED_KEYS=""
2. Library routines -> CJK 16x16 font & CJK 32x32 font，确认勾选。对应的是.config文件CONFIG_FONT_CJK_16x16=y & CONFIG_FONT_CJK_32x32=y
3. General setup -> Local version - append to kernel release，建议编辑添加下描述（在内核信息末尾添加-cjktty）。对应的是.config文件CONFIG_LOCALVERSION="-cjktty"
```
第一条我这边看直接就是空的，略过。

但是第二条我并没有找到这个选项，不过配置完成以后`cat .config | grep CJK`是能看到有这些配置项并且已经是y了的，不管他。

第三条就是在版本号后面加自定义后缀，如果你想像我一样装逼的话可以写什么`-dark495-cjktty`

## 编译
很简单，就执行
```shell
make INSTALL_MOD_STRIP=1 all -j64
```
简单说一下，`-j64`是代表同时跑64个编译任务，这个一般是取cpu核心数*2  
`INSTALL_MOD_STRIP=1`是去掉调试信息，让编译速度更快/系统性能更优/编译生成的文件体积更小。


之后，如果一切顺利没有报错的话，你就可以把你编译的内核安装到你的系统里了。
```shell
make INSTALL_MOD_STRIP=1 modules_install
make install
```
如果还是一切顺利没有报错的话，`reboot`请，在启动项列表你会看到你刚编译的内核，选择它，启动吧！

## 生成rpm包
在生成之前需要把你的源码目录变成git仓库目录，以下是指令。  
你不一定要完全按照我的方法来，实际上我并不知道需不需要`git add`和`git commit`。
```shell
git init
git config --global user.name "Dark495"
git config --global user.email "flandrestudio.cn@gmail.com"
git add .
git commit -m "shit world"
```

之后就开始编译并生成rpm吧
```shell
make INSTALL_MOD_STRIP=1 rpm-pkg -j64
```
如果一切顺利，那么`ls rpmbuild/RPMS/x86_64/`。如果你看到了三个文件，那么恭喜你。

# 关于本文
本文作者文化水平不高，~~并且写的时候有点喝多~~ ，用词可能会出现拗口或那啥 总之不要在意细节，嗯，不接受此类的issues。

你也可以看看我的主页或推特，然后你就会发现 ~~这他妈啥啊~~
