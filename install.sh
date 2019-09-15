#!/bin/bash
lynx -source "https://raw.githubusercontent.com/bongochong/WinScreenyReborn/master/screeny.sh" > ~/screeny.sh
chmod +x ~/screeny.sh
ln -s ~/screeny.sh ~/screeny
mv ~/screeny /bin/
echo "Successfully installed!"
