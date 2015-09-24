#!/bin/bash

if [ "$(id -u)" != "0" ]; then
	echo "Please run script with sudo or as root"
	exit 1
fi
#shell setup section
################################################################################

grep -q -F '$(chef shell-init bash)' ~/.bash_profile || echo '$(chef shell-init bash)' >> ~/.bash_profile

#######################end of shell setup section###############################

#downloads section
if [ -f ~/Downloads/chefdk.sh ]
  then
    rm ~/Downloads/chefdk.sh
fi
echo "downloading chefdk"
curl -kLo ~/Downloads/chefdk.sh https://www.getchef.com/chef/install.sh
if [ ! -f ~/Downloads/chefdk.sh ]
  then
    echo "chefdk download failed, check network and try again later"
		exit 1
fi
#sourceforge messed with git download until I hard linked the version
if [ -f ~/Downloads/git.dmg ]
  then
    rm ~/Downloads/git.dmg
fi
echo "downloading git"
curl -kLo ~/Downloads/git.dmg http://downloads.sourceforge.net/project/git-osx-installer/git-2.5.3-intel-universal-mavericks.dmg
if [ ! -f ~/Downloads/git.dmg ]
  then
		echo "git download failed, check network and try again later"
		exit 1
fi
if [ -f ~/Downloads/atom.zip ]
  then
    rm ~/Downloads/atom.zip
fi
echo "downloading atom"
curl -kLo ~/Downloads/atom.zip https://atom.io/download/mac
if [ ! -f ~/Downloads/atom.zip ]
  then
		echo "atom download failed, check network and try again later"
		exit 1
fi
if [ -f ~/Downloads/gitdesktop.zip ]
  then
    rm ~/Downloads/gitdesktop.zip
fi
echo "downloading git desktop"
curl -kLo ~/Downloads/gitdesktop.zip https://central.github.com/mac/latest
if [ ! -f ~/Downloads/gitdesktop.zip ]
  then
		echo "git desktop download failed, check network and try again later"
		exit 1
fi
#no apparent way to find latest version of vagrant easily, update the below url for new versions
if [ -f ~/Downloads/vagrant.dmg ]
  then
    rm ~/Downloads/vagrant.dmg
fi
echo "downloading vagrant"
curl -kLo ~/Downloads/vagrant.dmg https://dl.bintray.com/mitchellh/vagrant/vagrant_1.7.4.dmg
if [ ! -f ~/Downloads/vagrant.dmg ]
  then
		echo "vagrant desktop download failed, check network and try again later"
		exit 1
fi
#update below to the latest after 5.0 release is fixed (see https://www.virtualbox.org/ticket/14590)
if [ -f ~/Downloads/virtualbox.dmg ]
  then
    rm ~/Downloads/virtualbox.dmg
fi
echo "downloading virtualbox"
curl -o ~/Downloads/virtualbox.dmg http://download.virtualbox.org/virtualbox/4.3.30/VirtualBox-4.3.30-101610-OSX.dmg
if [ ! -f ~/Downloads/virtualbox.dmg ]
  then
		echo "virtualbox desktop download failed, check network and try again later"
		exit 1
fi


#install section
#chefdk
echo "installing chefdk"
#remove old install
if [ -f /opt/chefdk ]
  then
    rm -rf /opt/chefdk
    pkgutil --forget com.getchef.pkg.chefdk
    find /usr/bin -lname '/opt/chefdk/*' -delete
fi
#install new
sh ~/Downloads/chefdk.sh -P chefdk
echo "chefdk installed"

#github
echo "installing git"
hdiutil attach ~/Downloads/git.dmg -mountpoint /Volumes/git
#remove old install
sh /Volumes/git/uninstall.sh
#install new
installer -pkg /Volumes/git/*.pkg -target /
echo "git installed"

#atom
echo "installing atom"
unzip -q ~/Downloads/atom.zip -d ~/Downloads/atom
osascript -e 'quit app "Atom"'
#remove old install
if [ -d /Applications/Atom.app ]
  then
		echo "removing existing Atom"
    rm -Rf /Applications/Atom.app
fi
#install new
cp -a ~/Downloads/atom/*.app /Applications/
echo "atom installed"

#gitdesktop
echo "installing github desktop"
unzip -q ~/Downloads/gitdesktop.zip -d ~/Downloads/gitdesktop
osascript -e 'quit app "GitHub Desktop"'
#remove old install
if [ -d /Applications/GitHub\ Desktop.app ]
  then
		echo "removing existing GitHub Desktop"
    rm -Rf /Applications/GitHub\ Desktop.app
fi
#install new
cp -a ~/Downloads/gitdesktop/*.app /Applications/
echo "github desktop installed"

#vagrant
echo "installing vagrant"
hdiutil attach ~/Downloads/vagrant.dmg -mountpoint /Volumes/vagrant
#remove old install
sh /Volumes/vagrant/uninstall.tool
#install new
installer -pkg /Volumes/vagrant/*.pkg -target /
echo "vagrant installed"

#virtualbox
echo "installing virtualbox"
hdiutil attach ~/Downloads/virtualbox.dmg -mountpoint /Volumes/virtualbox
osascript -e 'quit app "VirtualBox"'
#remove old install
sh /Volumes/virtualbox/VirtualBox_Uninstall.tool
#install new
installer -pkg /Volumes/virtualbox/*.pkg -target /
echo "virtualbox installed"


#config section

#setup git defaults
echo "configuring git"
if [ -f /usr/bin/git ]
  then
    mv /usr/bin/git /usr/bin/git-system
fi

read -e -p "Enter your name (First Last): " GITNAME
git config --global user.name $GITNAME
read -e -p "Enter your email: " GITEMAIL
git config --global user.email $GITEMAIL
git config --global core.autocrlf false
git config --global core.editor "atom --wait"
echo "git configured"

#cleanup section

echo "starting cleanup"
hdiutil detach /Volumes/git
hdiutil detach /Volumes/vagrant
hdiutil detach /Volumes/virtualbox
rm ~/Downloads/chefdk.sh
rm ~/Downloads/git.dmg
rm ~/Downloads/atom.zip
rm -rf ~/Downloads/atom/
rm ~/Downloads/gitdesktop.zip
rm -rf ~/Downloads/gitdesktop
rm ~/Downloads/vagrant.dmg
rm ~/Downloads/virtualbox.dmg
echo "cleanup complete"

echo "toolchain installation complete"
