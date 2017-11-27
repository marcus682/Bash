#!/bin/bash

if [ "$UID" -ne "0" ]
then
  echo "Il faut etre root pour executer ce script ==> sudo ./script.sh"
  exit 
fi 

echo "Profil à utiliser : "
echo -e "================================"
echo "[1] profil Simon (1) : Ubuntu 18.04/Gnome Shell"
echo "[2] profil Simon (2) : Debian 9/Xfce"
echo "[3] profil Simon (3) : Archlinux/Xfce"
echo "[4] (plus tard)"
echo "[5] profil assistance rectorat (1) : Ubuntu 18.04LTS/Gnome Shell"
echo "[6] profil assistance rectorat (2) : Debian 9/Xfce"
echo "[7] Etab scolaire : Ubuntu Mate 18.04/Mate"
echo "- - -"
echo "[10] BionicBeaver - profil générique"
echo "[11] Stretch - profil générique"
echo "[12] Arch - profil générique"
echo -e "================================"
read -p "Choix : " choixProfil

##################################
# Commun à tous - base Ubuntu 18.04
##################################
if [ "$choixProfil" = "1" ] || [ "$choixProfil" = "5" ] || [ "$choixProfil" = "7" ] || [ "$choixProfil" = "10" ]
then
  export DEBIAN_FRONTEND="noninteractive" #permet d'automatiser l'installation de certains logiciels
  # activation dépot partenaire si ce n'est pas encore fait
  sed -i "/^# deb .*partner/ s/^# //" /etc/apt/sources.list
  
  # nettoyage puis maj du système
  apt autoremove --purge -y && apt clean
  apt update && apt full-upgrade -y

  # outils utiles
  apt install curl inxi net-tools git gdebi openjdk-8-jre numlockx flatpak screenfetch debconf-utils -y
  # éditeur/bureautique
  apt install vim libreoffice libreoffice-l10n-fr libreoffice-help-fr libreoffice-templates evince -y
  echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | /usr/bin/debconf-set-selections | apt install ttf-mscorefonts-installer -y
  # codecs
  apt install x264 x265 -y
  # internet
  apt install firefox firefox-locale-fr chromium-browser chromium-browser-l10n-fr pidgin transmission-gtk thunderbird thunderbird-locale-fr -y
  # multimedia & graphisme
  apt install vlc gimp gimp-help-fr shutter -y
  # thème
  apt install arc-thene numix-blue-gtk-theme numix-gtk-theme numix-icon-theme breeze-icon-theme breeze-cursor-theme -y
  # désactivation message d'erreurs
  sed -i 's/^enabled=1$/enabled=0/' /etc/default/apport
  # inutile dans tous les cas
  apt purge ubuntu-web-launchers -y #icone amazon
  # optimisation swap
  echo vm.swappiness=5 | tee /etc/sysctl.d/99-swappiness.conf 
fi

##################################
# Commun à tous - base Debian 9
##################################
if [ "$choixProfil" = "2" ] || [ "$choixProfil" = "6" ] || [ "$choixProfil" = "11" ]
then
  export DEBIAN_FRONTEND="noninteractive" #permet d'automatiser l'installation de certains logiciels
  # activation des dépots utiles
  wget https://raw.githubusercontent.com/sibe39/linux_distrib/master/debian9-sources.list 
  mv -f debian9-sources.list /etc/apt/sources.list && dpkg --add-architecture i386 && apt update
  
  # nettoyage puis maj du système
  apt autoremove --purge -y && apt clean
  apt update && apt full-upgrade -y

  # outils utiles
  apt install curl net-tools inxi git openjdk-8-jre numlockx flatpak screenfetch debconf-utils -y
  # éditeur/bureautique
  apt install vim libreoffice libreoffice-l10n-fr libreoffice-help-fr evince -y
  echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | /usr/bin/debconf-set-selections | apt install ttf-mscorefonts-installer -y
  # codecs
  apt install x264 x265 -y
  # internet
  apt install firefox-esr firefox-esr-l10n-fr chromium chromium-l10n pidgin transmission-gtk -y
  # multimedia & graphisme
  apt install vlc gimp gimp-help-fr shutter -y
  # thème
  apt install arc-thene numix-gtk-theme numix-icon-theme breeze-icon-theme breeze-cursor-theme -y
  # optimisation swap
  echo vm.swappiness=5 | tee /etc/sysctl.d/99-swappiness.conf   
fi

##################################
# Commun à tous - base Arch
##################################
if [ "$choixProfil" = "3" ] || [ "$choixProfil" = "12" ]
then  
  # nettoyage puis maj du système
  pacman --noconfirm -Sc
  pacman --noconfirm -Syyu
  
  # outils utiles
  pacman --noconfirm -S inxi curl net-tools git jre8-openjdk numlockx flatpak screenfetch 
  # éditeur/bureautique
  pacman --noconfirm -S vim libreoffice-fresh libreoffice-fresh-fr evince
  # codecs
  pacman --noconfirm -S x264 x265
  # internet
  pacman --noconfirm -S firefox firefox-i18n-fr chromium pidgin transmission-gtk
  # multimedia & graphisme
  pacman --noconfirm -S vlc gimp gimp-help-fr
  # thème
  pacman --noconfirm -S numix-gtk-theme breeze-gtk breeze-icons
  # optimisation swap
  echo vm.swappiness=5 | tee /etc/sysctl.d/99-swappiness.conf     
fi

##################################
# Supplément spécifique suivant profil
##################################

## spécifique profil 1 sur Ubuntu avec Gnome Shell (Simon)
if [ "$choixProfil" = "1" ] 
then
  #optimisation
  mv /snap /home/ && ln -s /home/snap /snap #déportage snappy dans /home pour alléger racine (/ et /home séparé)
  swapoff /swapfile && rm /swapfile && sed -i -e '/.swapfile*/d' /etc/fstab #désactivation swap
  sed -ri 's/GRUB_TIMEOUT=10/GRUB_TIMEOUT=2/g' /etc/default/grub && mkdir /boot/old && mv /boot/memtest86* /boot/old/ ; update-grub #pour grub
  gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize' #comportement gnome
  
  #cmd supplémentaire1 : pour toutes les maj (utilisation : maj)
  echo "alias maj='sudo apt update && sudo apt autoremove --purge -y && sudo apt full-upgrade -y && sudo apt clean && sudo snap refresh && sudo flatpak update -y ; clear'" >> /home/$SUDO_USER/.bashrc
 
  #cmd supplémentaire2 : pour contournement temporaire wayland pour des applis comme gparted... (ex utilisation : fraude gparted)
  echo "#contournement wayland pour certaines applis
  fraude(){ 
    xhost + && sudo \$1 && xhost -
    }" >> /home/$SUDO_USER/.bashrc
  
  su $SUDO_USER ; source /home/$SUDO_USER/.bashrc ; exit
     

  apt install dconf-editor gnome-tweak-tool folder-color gnome-packagekit synaptic -y
  apt install htop gparted ppa-purge unrar ubuntu-restricted-extras ffmpegthumbnailer -y
  
  # Création répertoire extension pour l'ajout d'extension supplémentaire pour l'utilisateur principal
  mkdir /home/$SUDO_USER/.local/share/gnome-shell/extensions && chown -R $SUDO_USER /home/$SUDO_USER/.local/share/gnome-shell/extensions

  # passage firefox vers n+1 (béta)
  add-apt-repository ppa:mozillateam/firefox-next -y  && apt update && apt upgrade -y
  # ajout déveloper édition (indépendant)
  flatpak install --from https://firefox-flatpak.mojefedora.cz/org.mozilla.FirefoxDevEdition.flatpakref -y
  # autres navigateurs
  apt install torbrowser-launcher -y
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' && apt update && apt install google-chrome-stable -y

  # outil web
  apt install pidgin pidgin-plugin-pack polari filezilla deluge grsync subdownloader chrome-gnome-shell -y
  snap install discord dino quasselclient-moon127 && snap install electrum --classic
  flatpak install --from https://flathub.org/repo/appstream/com.github.JannikHv.Gydl.flatpakref -y
  wget https://repo.skype.com/latest/skypeforlinux-64.deb && dpkg -i skypeforlinux-64.deb ; apt install -fy ; rm skypeforlinux-64.deb
  
  
  # multimedia
  apt install vlc-plugin-vlsub vlc-plugin-visualization gnome-mpv quodlibet gnome-twitch handbrake winff openshot -y
  snap install vlc #ajout d'une 2ème version de VLC indépendante (3.0dev)
  flatpak install --from https://flathub.org/repo/appstream/de.haeckerfelix.gradio.flatpakref -y
  wget https://desktop-auto-upgrade.s3.amazonaws.com/linux/1.8.0/molotov && mv molotov molotov.AppImage
  wget http://nux87.free.fr/script-postinstall-ubuntu/appimage/avidemux2.7.0.AppImage
  wget https://download.kde.org/unstable/kdenlive/16.12/linux/Kdenlive-16.12-rc-x86_64.AppImage
  wget http://download.opensuse.org/repositories/home:/ocfreitag/AppImage/owncloud-client-latest-x86_64.AppImage
  wget https://github.com/amilajack/popcorn-time-desktop/releases/download/v0.0.6/PopcornTime-0.0.6-x86_64.AppImage
  mkdir ./appimages ; mv *.AppImage ./appimages/ ; chmod -R +x ./appimages

  
  # graphisme/audio
  apt install pinta inkscape darktable audacity mixxx lame -y
  
  # supplément bureautique
  apt install geary pdfmod -y
  snap install mailspring
  flatpak install --from https://flathub.org/repo/appstream/org.gnome.FeedReader.flatpakref -y
  flatpak install --from https://flathub.org/repo/appstream/com.github.philip_scott.notes-up.flatpakref -y
  
  # utilitaires sup
  apt install kazam simplescreenrecorder virtualbox keepassx screenfetch asciinema ncdu screen rclone -y
  add-apt-repository "deb http://ppa.launchpad.net/gencfsm/ppa/ubuntu xenial main" -y && apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 6A0344470F68ADCA && apt update && apt install gnome-encfs-manager -y
  flatpak install --from https://flathub.org/repo/appstream/org.baedert.corebird.flatpakref -y

  # dev
  apt install emacs geany codeblocks codeblocks-contrib 
  snap install pycharm-community --classic ; snap install atom --classic
  
  # gaming
  apt install steam playonlinux minetest minetest-mod-nether openarena 0ad supertux supertuxkart teeworlds -y
  wget http://packages.linuxmint.com/pool/import/m/minecraft-installer/minecraft-installer_0.1+r12~ubuntu16.04.1_amd64.deb && dpkg -i minecraft-installer_0.1+r12~ubuntu16.04.1_amd64.deb ; apt install -fy ; rm minecraft-installer_0.1+r12~ubuntu16.04.1_amd64.deb
  snap install tic-tac-toe rubecube
  flatpak install --from https://flathub.org/repo/appstream/com.jagex.RuneScape.flatpakref -y   
  flatpak install --from https://flathub.org/repo/appstream/com.albiononline.AlbionOnline.flatpakref -y
  
  # extension
  apt install gnome-shell-extension-impatience gnome-shell-extension-weather gnome-shell-extension-system-monitor -y
  
  # nettoyage
  apt install -fy ; apt autoremove --purge -y ; apt clean ; clear
fi

## spécifique profil 2 sur Debian avec Xfce (Simon)
if [ "$choixProfil" = "2" ] 
then
  ## optimisation
  #cmd supplémentaire : pour les maj (utilisation : maj)
  echo "alias maj='sudo apt update && sudo apt autoremove --purge -y && sudo apt full-upgrade -y && sudo apt clean ; clear'" >> /home/$SUDO_USER/.bashrc
  su $SUDO_USER ; source /home/$SUDO_USER/.bashrc ; exit
   
  # Utiles 
  apt install synaptic htop gparted unrar -y
  
  # autre navigateur
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' && apt update && apt install google-chrome-stable -y

  # outil web
  apt install pidgin-plugin-pack polari filezilla deluge grsync subdownloader chrome-gnome-shell -y
  wget https://repo.skype.com/latest/skypeforlinux-64.deb && dpkg -i skypeforlinux-64.deb ; apt install -fy ; rm skypeforlinux-64.deb
  
  # multimedia
  apt install vlc-plugin-vlsub vlc-plugin-visualization gnome-mpv quodlibet handbrake winff openshot -y
  snap install vlc #ajout d'une 2ème version de VLC indépendante (3.0dev)
  wget http://nux87.free.fr/script-postinstall-ubuntu/appimage/avidemux2.7.0.AppImage
  wget https://download.kde.org/unstable/kdenlive/16.12/linux/Kdenlive-16.12-rc-x86_64.AppImage
  wget http://download.opensuse.org/repositories/home:/ocfreitag/AppImage/owncloud-client-latest-x86_64.AppImage
  mkdir ./appimages ; mv *.AppImage ./appimages/ ; chmod -R +x ./appimages

  # graphisme/audio
  apt install pinta inkscape darktable audacity mixxx lame -y
  
  # supplément bureautique
  apt install geary pdfmod -y
  
  # utilitaires sup
  apt install kazam simplescreenrecorder keepassx screenfetch asciinema ncdu screen rclone corebird -y

  # dev
  apt install emacs geany codeblocks codeblocks-contrib 
 
  # nettoyage
  apt install -fy ; apt autoremove --purge -y ; apt clean ; clear
fi

## spécifique profil 3 sur Arch avec Xfce (Simon)
if [ "$choixProfil" = "3" ] 
then
  pacman --noconfirm -S htop gparted unrar
 
  # outil web
  pacman --noconfirm -S hexchat filezilla deluge grsync subdownloader electrum avidemux-qt
  flatpak install --from https://firefox-flatpak.mojefedora.cz/org.mozilla.FirefoxDevEdition.flatpakref -y
  flatpak install --from https://flathub.org/repo/appstream/com.github.JannikHv.Gydl.flatpakref -y
  flatpak install --from https://flathub.org/repo/appstream/com.discordapp.Discord.flatpakref -y
  flatpak install --from https://flathub.org/repo/appstream/com.skype.Client.flatpakref -y
  flatpak install --from https://flathub.org/repo/appstream/org.baedert.corebird.flatpakref -y
  
  # multimedia
  pacman --noconfirm -S mpv quodlibet handbrake winff openshot
  wget https://download.kde.org/unstable/kdenlive/16.12/linux/Kdenlive-16.12-rc-x86_64.AppImage
  wget http://download.opensuse.org/repositories/home:/ocfreitag/AppImage/owncloud-client-latest-x86_64.AppImage
  wget https://github.com/amilajack/popcorn-time-desktop/releases/download/v0.0.6/PopcornTime-0.0.6-x86_64.AppImage
  mkdir ./appimages ; mv *.AppImage ./appimages/ ; chmod -R +x ./appimages

  
  # graphisme/audio
  pacman --noconfirm -S pinta inkscape darktable audacity mixxx lame
  
  # supplément bureautique
  pacman --noconfirm -S geary pdfmod
  
  # utilitaires sup
  pacman --noconfirm -S simplescreenrecorder virtualbox keepassx screenfetch asciinema ncdu screen rclone

  # dev
  pacman --noconfirm -S emacs geany codeblocks atom
  
  # gaming
  pacman --noconfirm -S minetest supertux supertuxkart teeworlds

  # nettoyage
  pacman --noconfirm -Sc
fi

## spécifique profil 4 : plus tard
if [ "$choixProfil" = "4" ] 
then


fi


## spécifique profil 5 : Ubuntu avec Gnome Shell (technicien assistance)
if [ "$choixProfil" = "5" ] 
then


fi

## spécifique profil 6 : Debian avec Xfce (technicien assistance)
if [ "$choixProfil" = "6" ] 
then


fi


## spécifique profil 7 : Ubuntu Mate (etab scolaire)
if [ "$choixProfil" = "7" ] 
then


fi

echo "Pour prendre en compte tous les changements, il faut maintenant redémarrer !"
read -p "Voulez-vous redémarrer immédiatement ? [o/n] " reboot
if [ "$reboot" = "o" ] || [ "$reboot" = "O" ]
then
    reboot
fi
