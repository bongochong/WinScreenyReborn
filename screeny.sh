#!/bin/bash
#
# Windows Screenfetch Fixed and Improved (Without the Screenshot functionality)
# Originally Hacked together by Nijikokun <nijikokun@gmail.com> 
# Improved and Modified by BitsByWill
# Fixed, Further Improved and Modified by chongobong
# License: GPLv3

version='0.7.1'

# Displayment
display=( Host KerVer Cpu OS Arch Shell GPU1 GPU2 Motherboard HDD Memory Uptime Resolution DE WM WMTheme Font )

# Color Loop
bld=$'\e[1m'
rst=$'\e[0m'
inv=$'\e[7m'
und=$'\e[4m'
f=3 b=4
for j in f b; do
  for i in {0..7}; do
    printf -v $j$i %b "\e[${!j}${i}m"
  done
done

det=$(cmd /c ver | tr -d '\r\n ' |  sed 's/[^0-9]*//g' | cut -c1-2)
if [ "$det" == "10" ] ; then
	y=1
elif [ "$det" == "62" ] ; then
	y=1
elif [ "$det" == "63" ] ; then
	y=1
else
	y=0
fi

help(){
	echo -e "${und}Usage${rst}:"
	echo -e "screeny (or preferred alias to 'sh screeny.sh') [Optional Flags]"
	echo ""
	echo "WinScreenyReborn - A CLI Bash Script to show System Information for Windows!"
	echo ""
	echo -e "${und}Options${rst}:"
	echo -e "    ${bld}-v${rst}                 Display script version"
	echo -e "    ${bld}-h${rst}                 Display this file"
}

# Flag Check
while getopts "vh" flags; do
	case $flags in
		h)
			help
			exit;;
		v)
			echo -e "${und}WinScreenyReborn${rst} - Version ${version}"
			echo ""
			echo -e "Copyright (C) Chongo Bong (AMK) (github.com/bongochong)"
			echo ""
			echo -e "Orginally cobbled together by Nijiko Yonskai (github.com/nijikokun)"
			echo ""
			echo -e "This is free software, under the GNU GPLv3 License: https://www.gnu.org/licenses/"
			echo ""
			echo -e "Source can be downloaded from: https://github.com/bongochong/WinScreenyReborn"
			exit;;
	esac
done

# Prevent Unix Output
unameOutput=`uname`
if [[ "$unameOutput" == 'Linux' ]] || [[ "$unameOutput" == 'Darwin' ]] ; then
    echo 'This script is for Windows only!'
    exit 0
fi

# Begin Detection
detectHost () {
	user=$(echo "$USER")
	host=$(hostname)
}

detectCpu () {
	cpu=$(awk -F':' '/model name/{ print $2 }' /proc/cpuinfo | head -n 1 | tr -s " " | sed 's/(R)//' | sed 's/(TM)//' | sed 's/(C)//' | sed 's/ CPU//' | sed 's/Co., //' | sed 's/Ltd., //' | sed 's/Co. //' | sed 's/Ltd. //' | sed "s/^[ \t]*//" | sed -e "s/[[:space:]]\+/ /g" | sed '/^$/d' | cut -c -63)
}

detectOS () {
	os=`wmic os get name | head -2 | tail -1 | sed 's/Microsoft //' | sed 's/Starter/Poverty/g' | sed 's/Basic/Toaster/g'`
	os=`expr match "$os" '\(Windows [A-Za-z0-9][ A-Za-z0-9]\+\)'`
}

detectArch () {
	arch=`wmic os get OSArchitecture | head -2 | tail -1 | tr -d '\r '`
}

detectKerVer(){
	kerVer=$(cmd /c ver | tr -d '\r\n ' | sed 's/MicrosoftWindows//g' | sed 's/Version//g' | sed 's/[][]//g')
}

detectHDD () {
	size=`df -H | grep -E '^[A-Z]\:\/?|File' | awk 'FNR==2{ print $2 }' | head -2 | tr -d '\r '`
	free=`df -H |  grep -E '^[A-Z]\:\/?|File' | awk 'FNR==2{ print $4 }' | head -2 | tr -d '\r '`
}

detectResolution () {
	if [ $y -eq 1 ] ; then
		width=`wmic path Win32_VideoController get CurrentHorizontalResolution | sed 's/[^0-9]*//g' | tr -d '\r\n'`
		height=`wmic path Win32_VideoController get CurrentVerticalResolution | sed 's/[^0-9]*//g' | tr -d '\r\n'`
	else
		width=`wmic desktopmonitor get screenwidth | grep -vE '[a-z]+' | tr -d '\r\n '`
		height=`wmic desktopmonitor get screenheight | grep -vE '[a-z]+' | tr -d '\r\n '`
	fi
}

detectUptime () {
	uptime=`awk -F. '{print $1}' /proc/uptime`
	secs=$((${uptime}%60))
	mins=$((${uptime}/60%60))
	hours=$((${uptime}/3600%24))
	days=$((${uptime}/86400))
	uptime="${mins}m"

	if [ "${hours}" -ne "0" ]; then
	  uptime="${hours}h ${uptime}"
	fi

	if [ "${days}" -ne "0" ]; then
	  uptime="${days}d ${uptime}"
	fi
}

detectMemory () {
	total_mem=$(awk '/MemTotal/ { print $2 }' /proc/meminfo)
	totalmem=$((${total_mem}/1024))
	free_mem=$(awk '/MemFree/ { print $2 }' /proc/meminfo)
	used_mem=$((${total_mem} - ${free_mem}))
	usedmem=$((${used_mem}/1024))
	mem="${usedmem}MB / ${totalmem}MB"
}

detectShell () {
	myshell=$(echo $SHELL | awk -F"/" '{print $NF}')
}

detectMotherboard () {
    board=`wmic baseboard get product,manufacturer | sed 's/Manufacturer  //' | sed 's/Product  //'| tr -d '\r\n' | sed 's/ \{2,\}/ /g' | sed 's/Co., //' | sed 's/Ltd., //' | sed 's/Co. //' | sed 's/Ltd. //' | sed "s/^[ \t]*//" | sed -e "s/[[:space:]]\+/ /g" | sed '/^$/d' | cut -c -63`
}

detectDE () {
	winver=`wmic os get version | grep -Eo "^[0-9]+\.[0-9]+"`
	if [ "$winver" == "10.0" ]; then
		de='Metro'
	elif [ "$winver" == "6.3" ]; then
		de='Metro'
	elif [ "$winver" == "6.2" ]; then
		de='Metro'
	elif [ "$winver" == "6.1" ]; then
		de='Aero'
	elif [ "$winver" == "6.0" ]; then
		de='Aero'
	elif [ "$winver" == "5.2" ]; then
		de='Luna'
	elif [ "$winver" == "5.1" ]; then
		de='Luna'
	else
		de='N/A'
	fi
}

detectWM () {
	bugn=`tasklist | grep -o 'bugn' | tr -d '\r \n'`
	wind=`tasklist | grep -o 'Windawesome' | tr -d '\r \n'`
	if [ "$bugn" = "bugn" ]; then
		wm="bug.n"
	elif [ "$wind" = "Windawesome" ]; then
		wm="Windawesome"
	else
		wm="DWM"
	fi
}

detectWMTheme () {
	themeFile="$(reg query 'HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes' /v 'CurrentTheme' | grep -o '[A-Z]:\\.*')"
	theme=$(echo $themeFile | awk -F"\\" '{print $NF}' | sed "s/.theme//")
}

detectFont () {
	fontect=$(cat $HOME/.minttyrc 2> /dev/null | grep '^Font=.*' | grep -o '[0-9A-Za-z ]*$')
	if [ -z "$fontect" ]; then
		fontect="Lucida Console"
	fi
}

detectGPU1(){
	gpuNameA=$(wmic path win32_VideoController get name | awk 'FNR==2{ print $0 }' | sed 's/(R)//' | sed 's/(TM)//' | sed 's/(C)//' | sed 's/Co., //' | sed 's/Ltd., //' | sed 's/Co. //' | sed 's/Ltd. //' | sed "s/^[ \t]*//" | sed -e "s/[[:space:]]\+/ /g" | sed '/^$/d' | cut -c -63)
}

detectGPU2(){
	gpuNameB=$(wmic path win32_VideoController get name | awk 'FNR==3{ print $0 }' | sed 's/(R)//' | sed 's/(TM)//' | sed 's/(C)//' | sed 's/Co., //' | sed 's/Ltd., //' | sed 's/Co. //' | sed 's/Ltd. //' | sed "s/^[ \t]*//" | sed -e "s/[[:space:]]\+/ /g" | sed '/^$/d' | cut -c -63)
	if [ -z "$gpuNameB" ]; then
		gpuNameB="N/A"
	fi
}

# Loops :>
for i in "${display[@]}"; do
	[[ "${display[*]}" =~ "$i" ]] && detect${i}
done

# Output
if [ $y -eq 1 ] ; then
cat << EOF
$f1
$f2                            ,L2E@B@BB2         ${f1}${user}${f7}@${f3}${host}
$f2                   G8BBBB@@@B@BM@@@BB@B7          
$f1    r;kO@B@O@@B@@M $f2@MM@M@M@@@@BO@BBB@M@i       ${f1}OS: ${f7}${os} ${arch}
$f1   M@BMB@@M@M@MMM@ $f2@B@@@MM@@M@M@B@@@M@Or       ${f1}Kernel: ${f7}Version $kerVer
$f1   Z@@@M@M@B@MB@B@ $f2;@@B@@M@@@O@B@B@O@M@i       ${f1}CPU: ${f7}${cpu}
$f1   O@@B@B@MBB@BBBB $f2@@MB@@B@@@@MBMB@@@@Mr       ${f1}HDD: ${f7}$free / $size
$f1   8@M@@@@B@@B@@BM $f2@@MMB@@BO@BBM@BBBM@@7       ${f1}Memory: ${f7}${mem}
$f1   BB@@@BMM@MBB@@M $f2@BB@@BMBMB@@@@B@@@BBB7      ${f1}Uptime: ${f7}$uptime
$f1   M@@M@@M@@B@@O@@ $f2@M@@@@@@@@@B@@@MBBBM@7      ${f1}Resolution: ${f7}$width x $height
                                               ${f1}Motherboard: ${f7}$board
$f4   8@O@@BB@@@B@@@@ $f3@M@B@@@B@@@@@B@M@@@@Mi      ${f1}GPU 1: ${f7}$gpuNameA
$f4   EBB@@@@M@@@MBM@ $f3@@@@@M@BBB@B@@M@@@@Mvj      ${f1}GPU 2: ${f7}$gpuNameB
$f4   E@B@@B@BM@@B@@B $f3@M@B@@@M@M@M@@B@@@@B@;      ${f1}Shell: ${f7}$myshell
$f4   ZB@B@@@MMBMM@M@ $f3@B@@BM@MBBBB@@@BMO@Mr       ${f1}DE: ${f7}$de
$f4   E@B@O@M@BB@@O@B $f3@MM@@BMBMB@@M@BBM@BBr       ${f1}WM: ${f7}$wm
$f4   Z@@BBB@@@MBMM@B $f3@M@B@O@MB@@B@B@@@B@@7       ${f1}WM Theme: ${f7}$theme
$f4    vvqM@O@B@M@@B@ $f3@@@@B@@BO@MM@@MB@@B@i       ${f1}Font: ${f7}$fontect
$f4           ,. @@@B $f3@@BBB@@@@@@B@@B@@L                   
$f3                         i750@MBMBu
	$rst
EOF
else
cat <<EOF
$f1
$f1         ,.=:^!^!t3Z3z.,                ${f1}${user}${f7}@${f3}${host}
$f1        :tt:::tt333EE3                  
$f1        Et:::ztt33EEE  $f2@Ee.,      ..,   ${f1}OS: ${f7}${os} ${arch}
$f1       ;tt:::tt333EE7 $f2;EEEEEEttttt33#   ${f1}Kernel: ${f7}Version $kerVer
$f1      :Et:::zt333EEQ.$f2 SEEEEEttttt33QL   ${f1}CPU: ${f7}${cpu}
$f1      it::::tt333EEF $f2@EEEEEEttttt33F    ${f1}HDD: ${f7}$free / $size
$f1     ;3=*^\`\`\`'*4EEV $f2:EEEEEEttttt33@.    ${f1}Memory: ${f7}${mem}
$f4     ,.=::::it=., $f1\` $f2@EEEEEEtttz33QF     ${f1}Uptime: ${f7}$uptime
$f4    ;::::::::zt33)   $f2'4EEEtttji3P*      ${f1}Resolution: ${f7}$width x $height
$f4   :t::::::::tt33.$f3:Z3z..  $f2\`\` $f3,..g.      ${f1}Motherboard: ${f7}$board
$f4   i::::::::zt33F$f3 AEEEtttt::::ztF       ${f1}GPU 1: ${f7}$gpuNameA
$f4  ;:::::::::t33V $f3;EEEttttt::::t3        ${f1}GPU 2: ${f7}$gpuNameB
$f4  E::::::::zt33L $f3@EEEtttt::::z3F        ${f1}Shell: ${f7}$myshell
$f4 {3=*^\`\`\`'*4E3) $f3;EEEtttt:::::tZ\`        ${f1}DE: ${f7}$de
$f4             \` $f3:EEEEtttt::::z7          ${f1}WM: ${f7}$wm
$f3                 $f3'VEzjt:;;z>*\`          ${f1}WM Theme: ${f7}$theme
					${f1}Font: ${f7}$fontect
										 $rst	 
EOF
fi
