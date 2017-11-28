#!/bin/bash
# NE PAS UTILISER MERCI !


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
echo "[4] profil Simon (4) : Solus/Budgie"
echo "[5] profil Corinne : LinuxMint/Cinnamon"
echo "[6] profil assistance rectorat (1) : Ubuntu 18.04LTS/Gnome Shell"
echo "[7] profil assistance rectorat (2) : Debian 9/Xfce"
echo "[8] Etab scolaire : Ubuntu Mate 18.04/Mate"
echo "[9] profil formateur/prof : Ubuntu 18.04/Gnome Shell"
echo "[10] The FB Choice : Archlinux/Mate"
echo "[11] The N62 Choice : Xubuntu/Xfce"
echo "[12] Mode Pyshopathe (pour Archlinux)"
echo "- - -"
echo "[100] BionicBeaver - profil générique"
echo "[101] Stretch - profil générique"
echo "[102] Arch - profil générique"
echo -e "================================"
read -p "Choix : " choixProfil

##################################
# Commun à tous - base Ubuntu 18.04
##################################
if [ "$choixProfil" = "1" ] || [ "$choixProfil" = "5" ] || [ "$choixProfil" = "6" ] || [ "$choixProfil" = "8" ] || [ "$choixProfil" = "9" ] || [ "$choixProfil" = "11" ] || [ "$choixProfil" = "100" ]
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
if [ "$choixProfil" = "2" ] || [ "$choixProfil" = "7" ] || [ "$choixProfil" = "101" ]
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
if [ "$choixProfil" = "3" ] || [ "$choixProfil" = "10" ] || [ "$choixProfil" = "12" ] || [ "$choixProfil" = "102" ]
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

## spécifique profil 4 : Solus/Budgie
if [ "$choixProfil" = "4" ] 
then


#.....................................................


fi


## spécifique profil 5 : Mint/C
if [ "$choixProfil" = "5" ] 
then





#.....................................................







fi


## spécifique profil 6 : Ubuntu avec Gnome Shell (technicien assistance)
if [ "$choixProfil" = "6" ] 
then
  #optimisation
  mv /snap /home/ && ln -s /home/snap /snap #déportage snappy dans /home pour alléger racine (/ et /home séparé)
  #swapoff /swapfile && rm /swapfile && sed -i -e '/.swapfile*/d' /etc/fstab #désactivation swap
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
     
  apt install dconf-editor gnome-tweak-tool folder-color gnome-packagekit -y
  apt install htop gparted ppa-purge unrar ubuntu-restricted-extras -y
  
  # Création répertoire extension pour l'ajout d'extension supplémentaire pour l'utilisateur principal
  mkdir /home/$SUDO_USER/.local/share/gnome-shell/extensions && chown -R $SUDO_USER /home/$SUDO_USER/.local/share/gnome-shell/extensions

  # passage firefox vers n+1 (béta)
  #add-apt-repository ppa:mozillateam/firefox-next -y  && apt update && apt upgrade -y
  
  # ajout déveloper édition (indépendant)
  flatpak install --from https://firefox-flatpak.mojefedora.cz/org.mozilla.FirefoxDevEdition.flatpakref -y

  # outil web
  apt install pidgin pidgin-plugin-pack polari filezilla grsync -y
  # Teamviewer 8 pour assistance (bien qu'elle soit obsolète)
  wget http://download.teamviewer.com/download/version_8x/teamviewer_linux.deb && dpkg -i teamviewer_linux.deb ; apt install -fy ; rm teamviewer_linux.deb 
 
  # graphisme
  apt install pinta inkscape -y
  
  # supplément bureautique
  apt install zim geary pdfmod -y
  flatpak install --from https://flathub.org/repo/appstream/com.github.philip_scott.notes-up.flatpakref -y #alternative à zim
  
  # utilitaires sup
  apt install kazam virtualbox keepassx keepass2 screenfetch asciinema ncdu screen -y

  # dev
  apt install geany codeblocks codeblocks-contrib 
  snap install pycharm-community --classic 
 
  # nettoyage
  apt install -fy ; apt autoremove --purge -y ; apt clean ; clear
fi

## spécifique profil 7 : Debian avec Xfce (technicien assistance)
if [ "$choixProfil" = "7" ] 
then
  #optimisation
  apt install snapd -y
  mv /snap /home/ && ln -s /home/snap /snap #déportage snappy dans /home pour alléger racine (/ et /home séparé)
  #swapoff /swapfile && rm /swapfile && sed -i -e '/.swapfile*/d' /etc/fstab #désactivation swap
  sed -ri 's/GRUB_TIMEOUT=10/GRUB_TIMEOUT=2/g' /etc/default/grub && mkdir /boot/old && mv /boot/memtest86* /boot/old/ ; update-grub #pour grub

  #cmd supplémentaire1 : pour toutes les maj (utilisation : maj)
  echo "alias maj='sudo apt update && sudo apt autoremove --purge -y && sudo apt full-upgrade -y && sudo apt clean && sudo snap refresh && sudo flatpak update -y ; clear'" >> /home/$SUDO_USER/.bashrc
     
  apt install htop gparted unrar -y
  
  # ajout déveloper édition (indépendant)
  flatpak install --from https://firefox-flatpak.mojefedora.cz/org.mozilla.FirefoxDevEdition.flatpakref -y

  # outil web
  apt install pidgin polari filezilla grsync -y
  # Teamviewer 8 pour assistance (bien qu'elle soit obsolète)
  wget http://download.teamviewer.com/download/version_8x/teamviewer_linux.deb && dpkg -i teamviewer_linux.deb ; apt install -fy ; rm teamviewer_linux.deb 
 
  # graphisme
  apt install pinta inkscape -y
  
  # supplément bureautique
  apt install zim geary pdfmod -y
  flatpak install --from https://flathub.org/repo/appstream/com.github.philip_scott.notes-up.flatpakref -y #alternative à zim
  
  # utilitaires sup
  apt install kazam virtualbox keepassx keepass2 screenfetch asciinema ncdu screen -y

  # dev
  apt install geany codeblocks codeblocks-contrib 
  snap install pycharm-community --classic 
 
  # nettoyage
  apt install -fy ; apt autoremove --purge -y ; apt clean ; clear
fi


## spécifique profil 8 : Ubuntu Mate (etab scolaire)
if [ "$choixProfil" = "8" ] 
then
  apt install idle-python3.5 libreoffice-style-breeze sane -y

  #google earth
  wget --no-check-certificate https://dl.google.com/dl/earth/client/current/google-earth-pro-stable_current_amd64.deb
  dpkg -i google-earth-pro-stable_current_amd64.deb ; apt install -fy

  #celestia
  wget https://raw.githubusercontent.com/BionicBeaver/Divers/master/CelestiaBionic.sh ; chmod +x CelestiaBionic.sh
  ./CelestiaBionic.sh ; rm CelestiaBionic.sh
 
  # drivers imprimantes
  wget http://www.openprinting.org/download/printdriver/debian/dists/lsb3.2/contrib/binary-amd64/openprinting-gutenprint_5.2.7-1lsb3.2_amd64.deb
  dpkg -i openprinting-gutenprint_5.2.7-1lsb3.2_amd64.deb ; apt install -fy
  
  # java8
  add-apt-repository "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" -y
  apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 7B2C3B0889BF5709A105D03AC2518248EEA14886
  apt update && echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections | apt install oracle-java8-installer -y
  
  #bureautique
  apt install libreoffice libreoffice-gtk libreoffice-l10n-fr freeplane scribus gnote xournal cups-pdf -y
  #web
  apt install adobe-flashplugin -y
  #video/audio
  apt install x264 x265 imagination openshot audacity ffmpeg2theora flac vorbis-tools lame oggvideotools mplayer ogmrip goobox -y
  #graphisme/photo
  apt install blender sweethome3d gimp pinta inkscape gthumb mypaint hugin shutter -y
  #système
  apt install gparted vim pyrenamer rar unrar htop diodon p7zip-full gdebi -y
  #wireshark
  debconf-set-selections <<< "wireshark-common/install-setuid true" ; apt install wireshark -y
  #math
  apt install geogebra algobox carmetal scilab -y
  #science
  apt install stellarium avogadro -y
  #prog
  apt install scratch ghex geany imagemagick gcolor2 python3-pil.imagetk python3-pil traceroute python3-tk -y
  #gdevelop
  
  #nettoyage
  apt install -fy ; apt autoremove --purge -y ; apt clean -y  
fi

## spécifique profil 9 : Ubuntu avec GS (formateur/prof)
if [ "$choixProfil" = "9" ] 
then
  gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize' #comportement gnome
  #cmd supplémentaire1 : pour toutes les maj (utilisation : maj)
  echo "alias maj='sudo apt update && sudo apt autoremove --purge -y && sudo apt full-upgrade -y && sudo apt clean && sudo snap refresh && sudo flatpak update -y ; clear'" >> /home/$SUDO_USER/.bashrc
  #cmd supplémentaire2 : pour contournement temporaire wayland pour des applis comme gparted... (ex utilisation : fraude gparted)
  echo "#contournement wayland pour certaines applis
  fraude(){ 
    xhost + && sudo \$1 && xhost -
    }" >> /home/$SUDO_USER/.bashrc
    
  apt install gnome-tweak-tool folder-color -y
  apt install htop gparted ppa-purge unrar ubuntu-restricted-extras ffmpegthumbnailer -y
  su $SUDO_USER ; source /home/$SUDO_USER/.bashrc ; exit
  #bureautique
  apt install libreoffice libreoffice-gtk libreoffice-l10n-fr pdfmod -y
  flatpak install --from https://flathub.org/repo/appstream/com.github.philip_scott.notes-up.flatpakref -y
  #scenari
  echo "deb https://download.scenari.org/deb xenial main" > /etc/apt/sources.list.d/scenari.list
  wget -O- https://download.scenari.org/deb/scenari.asc | apt-key add -
  apt update && apt install scenarichain4.2.fr-fr opale3.6.fr-fr -y
  #web
  apt install adobe-flashplugin pidgin filezilla hexchat -y
  #video/audio
  apt install openshot audacity gnome-mpv -y
  wget https://download.kde.org/unstable/kdenlive/16.12/linux/Kdenlive-16.12-rc-x86_64.AppImage
  wget http://download.opensuse.org/repositories/home:/ocfreitag/AppImage/owncloud-client-latest-x86_64.AppImage
  mkdir ./appimages ; mv *.AppImage ./appimages/ ; chmod -R +x ./appimages
  #graphisme/photo
  apt install gimp pinta inkscape shutter -y
  #système
  apt install gparted vim rar unrar htop gdebi -y
  # dev
  apt install geany -y
  # utilitaires sup
  apt install kazam virtualbox keepass2 screenfetch -y
  # extension
  apt install gnome-shell-extension-weather -y
  
  # nettoyage
  apt install -fy ; apt autoremove --purge -y ; apt clean ; clear
fi

## spécifique profil 10 : Arch/Mate F.B Choice
if [ "$choixProfil" = "10" ] 
then

#........................

fi

## spécifique profil 11 : N62 choice
if [ "$choixProfil" = "11" ] 
then

#........................

fi

## spécifique profil 12 : psychopathe (sous Arch)
if [ "$choixProfil" = "12" ] 
then


fi





if [ "$reboot" = "o" ] || [ "$reboot" = "O" ]
then
    reboot
fi
