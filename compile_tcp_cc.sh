#!/bin/bash
#
# https://github.com/Aniverse/TrCtrlProToc0l
# Author: Aniverse
#
# bash <(curl -s https://raw.githubusercontent.com/Aniverse/TrCtrlProToc0l/master/compile_tcp_cc.sh) tsunami nanqinlang bbrplus
script_update=2019.04.25
script_version=1.0.2

tcp_cc=$1
#[[ -n $Outputs ]] && OutputLOG=">> $OutputLOG 2>&1"
[[ ! $tcp_cc =~ (tsunami|nanqinlang|bbrplus) ]] && echo -e "不支持！" && exit 1
function version_ge(){ test "$(echo "$@" | tr " " "\n" | sort -rV | head -1)" == "$1" ; }
filename=tcp_$tcp_cc.c
kernel_v=$(uname -r | cut -d- -f1)
kernel_v2=$(uname -r | cut -d- -f1 | cut -d. -f1-2)

version_ge $kernel_v 4.9.3 && [[ $tcp_cc == nanqinlang ]] && supported_list="4.9 4.10 4.11 4.12 4.13 4.14 4.15 4.16 4.17 4.18 4.19 4.20 5.0"
version_ge $kernel_v 4.10  && [[ $tcp_cc == tsunami ]]    && supported_list="4.10 4.11 4.12 4.13 4.14 4.15 4.16 4.17 4.18 4.19 4.20 5.0"
version_ge $kernel_v 4.14  && [[ $tcp_cc == bbrplus ]]    && supported_list="4.14 4.15 4.16 4.17 4.18 4.19 4.20 5.0"

mkdir compile_tcp_cc
cd compile_tcp_cc

for supported_kernel in $supported_list ; do
    [[ $kernel_v2 == $supported_kernel ]] &&
    wget https://raw.githubusercontent.com/Aniverse/seedbox-files/master/TCP.CC/$supported_kernel/$filename -O $filename --no-check-certificate
done
[[ ! -f $filename ]] && echo -e "下载源码失败！" && exit 1

echo "obj-m := tcp_$tcp_cc.o" > Makefile
mkdir -p /lib/modules/$(uname -r)/build
make -C /lib/modules/$(uname -r)/build M=$(pwd) modules CC=$(which gcc)
cp -rf tcp_$tcp_cc.ko /lib/modules/$(uname -r)/kernel/net/ipv4
insmod /lib/modules/$(uname -r)/kernel/net/ipv4/tcp_$tcp_cc.ko
depmod -a $OutputLOG

cd ..
rm -rf compile_tcp_cc
echo
