#!/bin/bash
## Version 1.0.1

# Objectif du script : automatiser l'installation des logiciels, drivers suivant le profil de l'utilisateur, cadre perso, familiale ou professionnel.

# Vérification que le script est lancé avec sudo (droit root nécessaire)
if [ "$UID" -ne "0" ]
then
  echo "Il faut etre root pour executer ce script ==> sudo ./script.sh"
  exit 
fi 

# Choix du profil pour l'utilisateur
echo "Profil à utiliser : "
echo -e "================================"
echo "[1] profil Simon (1) [Perso] Ubuntu 18.04/GS x64"
echo "[2] profil Simon (2) [Perso] Archlinux/Xfce x64"
echo "[3] profil Simon (3) [Travail] Ubuntu 18.04/GS x64"
echo "[4] profil Corinne [Perso] : LinuxMint 18/Cinnamon x64"
echo "[5] profil Raphael.B [Travail] Ubuntu 16.04/Unity x64"
echo -e "================================"
read -p "Choix : " choixProfil

# ----------------------------------------------------------------------------------------------------------------

##################################
# Commun à tous pour base Ubuntu
##################################
if [ "$choixProfil" = "1" ] || [ "$choixProfil" = "3" ] || [ "$choixProfil" = "4" ] || [ "$choixProfil" = "5" ]
then
  export DEBIAN_FRONTEND="noninteractive" #permet d'automatiser l'installation de certains logiciels
  # activation dépot partenaire si ce n'est pas encore fait
  sed -i "/^# deb .*partner/ s/^# //" /etc/apt/sources.list
  
  # nettoyage puis maj du système
  apt autoremove --purge -y && apt clean ; apt update && apt full-upgrade -y

  # outils utiles
  apt install htop gparted curl net-tools git gdebi openjdk-8-jre numlockx screenfetch -y
  
  # éditeur/bureautique
  apt install vim libreoffice libreoffice-l10n-fr libreoffice-help-fr evince -y
  
  # internet
  apt install firefox firefox-locale-fr chromium-browser chromium-browser-l10n pidgin transmission-gtk thunderbird thunderbird-locale-fr -y
  
  # multimedia, codecs & graphisme
  apt install vlc x264 x265 gimp gimp-help-fr shutter -y
  
  # désactivation message d'erreurs
  sed -i 's/^enabled=1$/enabled=0/' /etc/default/apport
  
  # inutile dans tous les cas
  apt purge ubuntu-web-launchers -y #suppression icone amazon
  
  # optimisation swap
  echo "vm.swappiness=5" > /etc/sysctl.d/99-swappiness.conf 
fi

# ----------------------------------------------------------------------------------------------------------------

##################################
# Commun à tous pour base Arch
##################################
if [ "$choixProfil" = "2" ] 
then  
  # nettoyage puis maj du système
  pacman --noconfirm -Sc ; pacman --noconfirm -Syyu
  
  # outils utiles
  pacman --noconfirm -S curl net-tools git jre8-openjdk numlockx screenfetch gparted 
  
  # éditeur/bureautique
  pacman --noconfirm -S vim libreoffice-fresh libreoffice-fresh-fr evince
  
  # internet
  pacman --noconfirm -S firefox firefox-i18n-fr chromium pidgin transmission-gtk
  
  # multimedia, codec & graphisme
  pacman --noconfirm -S vlc gimp gimp-help-fr x264 x265
  
  # optimisation swap
  echo vm.swappiness=5 | tee /etc/sysctl.d/99-swappiness.conf     
fi

##################################
# Supplément spécifique suivant profil
##################################

# ----------------------------------------------------------------------------------------------------------------

## spécifique profil 1 (Perso Simon 1 / Ubuntu 18.04 GS)
if [ "$choixProfil" = "1" ] 
then
  # Désactivation/Suppression du fichier swap
  swapoff /swapfile && rm /swapfile && sed -i -e '/.swapfile*/d' /etc/fstab #désactivation swap
  
  # Optimisation grub
  sed -ri 's/GRUB_TIMEOUT=10/GRUB_TIMEOUT=2/g' /etc/default/grub && mkdir /boot/old && mv /boot/memtest86* /boot/old/ ; update-grub 
  
  # Alias de commande pour simplifier Maj
  echo "alias maj='sudo apt update && sudo apt autoremove --purge -y && sudo apt full-upgrade -y && sudo apt clean && sudo snap refresh && sudo flatpak update -y ; clear'" >> /home/$SUDO_USER/.bashrc
 
  # Alias de commande pour pouvoir lancer une application graphique demandant l'accès root sur une session Wayland
  echo "#contournement wayland pour certaines applis
  fraude(){ 
    xhost + && sudo \$1 && xhost -
  }" >> /home/$SUDO_USER/.bashrc  
  
  # Prise en compte des alias
  su $SUDO_USER -c "source ~/.bashrc" 
  
  # Utile pour GS
  apt install dconf-editor gnome-tweak-tool folder-color gnome-packagekit synaptic flatpak -y
  apt install ppa-purge unrar ubuntu-restricted-extras ffmpegthumbnailer -y
  
  # Création répertoire extension pour l'ajout d'extension supplémentaire pour l'utilisateur principal
  mkdir /home/$SUDO_USER/.local/share/gnome-shell/extensions && chown -R $SUDO_USER /home/$SUDO_USER/.local/share/gnome-shell/extensions

  # Passage firefox vers n+1 (béta)
  add-apt-repository ppa:mozillateam/firefox-next -y  && apt update && apt upgrade -y
  
  # Autres navigateurs
  flatpak install --from https://firefox-flatpak.mojefedora.cz/org.mozilla.FirefoxDevEdition.flatpakref -y #firefox developer édition
  apt install torbrowser-launcher -y #tor browser
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' && apt update && apt install google-chrome-stable -y #chrome

  # Outil web
  apt install pidgin polari filezilla deluge grsync subdownloader -y
  snap install discord ; snap install electrum --classic
  flatpak install --from https://flathub.org/repo/appstream/com.github.JannikHv.Gydl.flatpakref -y #Gydl

  # Multimedia
  apt install gnome-mpv quodlibet gnome-twitch handbrake winff openshot -y
  flatpak install --from https://flathub.org/repo/appstream/de.haeckerfelix.gradio.flatpakref -y #Gradio
  wget https://desktop-auto-upgrade.s3.amazonaws.com/linux/1.8.0/molotov && mv molotov molotov.AppImage #Molotov
  wget https://download.kde.org/unstable/kdenlive/16.12/linux/Kdenlive-16.12-rc-x86_64.AppImage #KdenLive
  wget https://github.com/amilajack/popcorn-time-desktop/releases/download/v0.0.6/PopcornTime-0.0.6-x86_64.AppImage #PopcornTime
  mkdir /home/$SUDO_USER/appimages ; mv *.AppImage /home/$SUDO_USER/appimages/ ; chmod -R +x /home/$SUDO_USER/appimages/
  
  # Graphisme/audio
  apt install pinta inkscape darktable audacity mixxx lame -y
  
  # supplément bureautique
  apt install geary pdfmod -y
  snap install mailspring
  flatpak install --from https://flathub.org/repo/appstream/org.gnome.FeedReader.flatpakref -y #Feedreader
  flatpak install --from https://flathub.org/repo/appstream/com.github.philip_scott.notes-up.flatpakref -y #Notes Up
  
  # Autres outils
  apt install kazam simplescreenrecorder virtualbox keepassx asciinema ncdu screen rclone -y
  add-apt-repository "deb http://ppa.launchpad.net/gencfsm/ppa/ubuntu xenial main" -y && apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 6A0344470F68ADCA && apt update && apt install gnome-encfs-manager -y
  flatpak install --from https://flathub.org/repo/appstream/org.baedert.corebird.flatpakref -y #Corebird

  # Programmation
  apt install emacs geany codeblocks -y 
  snap install pycharm-community --classic
  
  # Gaming
  apt install steam playonlinux minetest openarena 0ad supertux supertuxkart teeworlds -y
  wget http://packages.linuxmint.com/pool/import/m/minecraft-installer/minecraft-installer_0.1+r12~ubuntu16.04.1_amd64.deb && dpkg -i minecraft-installer_0.1+r12~ubuntu16.04.1_amd64.deb ; apt install -fy ; rm minecraft-installer_0.1+r12~ubuntu16.04.1_amd64.deb #Minecraft
  snap install tic-tac-toe rubecube
  flatpak install --from https://flathub.org/repo/appstream/com.jagex.RuneScape.flatpakref -y #Runescape
  flatpak install --from https://flathub.org/repo/appstream/com.albiononline.AlbionOnline.flatpakref -y #Albion Online
  
  # Extensions
  apt install gnome-shell-extension-impatience gnome-shell-extension-weather gnome-shell-extension-system-monitor gnome-shell-extension-dash-to-panel -y
  #User theme
  wget https://extensions.gnome.org/extension-data/user-theme%40gnome-shell-extensions.gcampax.github.com.v32.shell-extension.zip
  unzip user-theme@gnome-shell-extensions.gcampax.github.com.v32.shell-extension.zip -d /home/$SUDO_USER/.local/share/gnome-shell/extensions/user-theme@gnome-shell-extensions.gcampax.github.com
  #Dash To Dock
  wget https://extensions.gnome.org/extension-data/dash-to-dock%40micxgx.gmail.com.v61.shell-extension.zip
  unzip dash-to-dock@micxgx.gmail.com.v61.shell-extension.zip -d /home/$SUDO_USER/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com
  #Removal drive menu
  wget https://extensions.gnome.org/extension-data/drive-menu%40gnome-shell-extensions.gcampax.github.com.v35.shell-extension.zip
  unzip drive-menu@gnome-shell-extensions.gcampax.github.com.v35.shell-extension.zip -d /home/$SUDO_USER/.local/share/gnome-shell/extensions/drive-menu@gnome-shell-extensions.gcampax.github.com
  #Workspace indicator
  wget https://extensions.gnome.org/extension-data/workspace-indicator%40gnome-shell-extensions.gcampax.github.com.v34.shell-extension.zip
  unzip workspace-indicator@gnome-shell-extensions.gcampax.github.com.v34.shell-extension.zip -d /home/$SUDO_USER/.local/share/gnome-shell/extensions/workspace-indicator@gnome-shell-extensions.gcampax.github.com
  #AppFolders Management
  wget https://extensions.gnome.org/extension-data/appfolders-manager%40maestroschan.fr.v11.shell-extension.zip
  unzip appfolders-manager@maestroschan.fr.v11.shell-extension.zip -d /home/$SUDO_USER/.local/share/gnome-shell/extensions/appfolders-manager@maestroschan.fr          

  su $SUDO_USER -c "gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'" #Minimisation fenêtre sur clique pour DtD
  
  # nettoyage
  apt install -fy ; apt autoremove --purge -y ; apt clean ; clear
fi

# ----------------------------------------------------------------------------------------------------------------

## spécifique profil 2 (Simon / ArchLinux avec Xfce)
if [ "$choixProfil" = "2" ] 
then
  # Outils utiles
  pacman --noconfirm -S htop unrar flatpak snapd simplescreenrecorder virtualbox keepassx asciinema ncdu screen
 
  # Outil web
  pacman --noconfirm -S hexchat filezilla deluge grsync subdownloader electrum avidemux-qt
  flatpak install --from https://firefox-flatpak.mojefedora.cz/org.mozilla.FirefoxDevEdition.flatpakref -y #Firefox Dev Edition
  flatpak install --from https://flathub.org/repo/appstream/com.github.JannikHv.Gydl.flatpakref -y #Gydl
  flatpak install --from https://flathub.org/repo/appstream/com.discordapp.Discord.flatpakref -y #Discord
  flatpak install --from https://flathub.org/repo/appstream/org.baedert.corebird.flatpakref -y #Corebird
  
  # Multimedia
  pacman --noconfirm -S mpv quodlibet handbrake winff openshot
  wget https://download.kde.org/unstable/kdenlive/16.12/linux/Kdenlive-16.12-rc-x86_64.AppImage
  wget http://download.opensuse.org/repositories/home:/ocfreitag/AppImage/owncloud-client-latest-x86_64.AppImage
  wget https://github.com/amilajack/popcorn-time-desktop/releases/download/v0.0.6/PopcornTime-0.0.6-x86_64.AppImage
  mkdir ./appimages ; mv *.AppImage ./appimages/ ; chmod -R +x ./appimages

  # Graphisme/audio
  pacman --noconfirm -S pinta inkscape darktable audacity mixxx lame
  
  # Supplément bureautique
  pacman --noconfirm -S geary pdfmod
  
  # Programmation
  pacman --noconfirm -S emacs geany codeblocks atom
  
  # Gaming
  pacman --noconfirm -S minetest supertux supertuxkart teeworlds

  # Nettoyage
  pacman --noconfirm -Sc
fi

# ----------------------------------------------------------------------------------------------------------------

## spécifique profil 3 : Simon/Travail (Ubuntu 18.04 GS)
if [ "$choixProfil" = "3" ] 
then
  sed -ri 's/GRUB_TIMEOUT=10/GRUB_TIMEOUT=3/g' /etc/default/grub && mkdir /boot/old && mv /boot/memtest86* /boot/old/ ; update-grub #pour grub
  
  #Alias Maj
  echo "alias maj='sudo apt update && sudo apt autoremove --purge -y && sudo apt full-upgrade -y && sudo apt clean && sudo snap refresh && sudo flatpak update -y ; clear'" >> /home/$SUDO_USER/.bashrc
 
  #Alias contournement wayland
  echo "#contournement wayland pour certaines applis
  fraude(){ 
    xhost + && sudo \$1 && xhost -
    }" >> /home/$SUDO_USER/.bashrc
  
  # Prise en compte des alias
  su $SUDO_USER -c "source ~/.bashrc"
   
  # Outils utiles 
  apt install flatpak dconf-editor gnome-tweak-tool folder-color gnome-packagekit -y
  apt install ppa-purge unrar ubuntu-restricted-extras -y
  
  # Création répertoire extension pour l'ajout d'extension supplémentaire pour l'utilisateur principal
  mkdir /home/$SUDO_USER/.local/share/gnome-shell/extensions && chown -R $SUDO_USER /home/$SUDO_USER/.local/share/gnome-shell/extensions
  
  # Firefox dev édition
  flatpak install --from https://firefox-flatpak.mojefedora.cz/org.mozilla.FirefoxDevEdition.flatpakref -y

  # Outil web
  apt install pidgin pidgin-plugin-pack polari filezilla grsync -y
  # Teamviewer 8 pour assistance (bien qu'elle soit obsolète)
  wget http://download.teamviewer.com/download/version_8x/teamviewer_linux.deb && dpkg -i teamviewer_linux.deb ; apt install -fy ; rm teamviewer_linux.deb 
 
  # Graphisme
  apt install pinta inkscape -y
  
  # Supplément bureautique
  apt install zim geary pdfmod -y
  flatpak install --from https://flathub.org/repo/appstream/com.github.philip_scott.notes-up.flatpakref -y # Notes Up
  
  # Utilitaires sup
  apt install kazam virtualbox keepassx keepass2 asciinema ncdu screen -y

  # Programmation
  apt install geany codeblocks -y 
  snap install pycharm-community --classic 

  ## Extension Gnome utiles
  # User Thème
  wget https://extensions.gnome.org/extension-data/user-theme%40gnome-shell-extensions.gcampax.github.com.v32.shell-extension.zip
  unzip user-theme@gnome-shell-extensions.gcampax.github.com.v32.shell-extension.zip -d /home/$SUDO_USER/.local/share/gnome-shell/extensions/user-theme@gnome-shell-extensions.gcampax.github.com
  # DtD
  wget https://extensions.gnome.org/extension-data/dash-to-dock%40micxgx.gmail.com.v61.shell-extension.zip
  unzip dash-to-dock@micxgx.gmail.com.v61.shell-extension.zip -d /home/$SUDO_USER/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com
  # Remove Drive Menu
  wget https://extensions.gnome.org/extension-data/drive-menu%40gnome-shell-extensions.gcampax.github.com.v35.shell-extension.zip
  unzip drive-menu@gnome-shell-extensions.gcampax.github.com.v35.shell-extension.zip -d /home/$SUDO_USER/.local/share/gnome-shell/extensions/drive-menu@gnome-shell-extensions.gcampax.github.com
  # Impatience, Météo, Système Monitor
  apt install gnome-shell-extension-impatience gnome-shell-extension-weather gnome-shell-extension-system-monitor -y
  # Activation minimisation fenêtre pour DTD
  su $SUDO_USER -c "gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'"
 
  ## Driver
  # Imprimante du travail (Kyocera Taskalfa 3511i)
  wget https://raw.githubusercontent.com/dane-lyon/fichier-de-config/master/Kyocera_taskalfa_3511i.PPD
  mv Kyocera_taskalfa_3511i.PPD /etc/cups/ppd/
  
  # nettoyage
  apt install -fy ; apt autoremove --purge -y ; apt clean ; clear
fi

# ----------------------------------------------------------------------------------------------------------------

## spécifique profil 4 : Corinne/Mint
if [ "$choixProfil" = "4" ] 
then
  sed -ri 's/GRUB_TIMEOUT=10/GRUB_TIMEOUT=2/g' /etc/default/grub && mkdir /boot/old && mv /boot/memtest86* /boot/old/ ; update-grub #pour grub

  # Navigateur supplémentaire
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' && apt update && apt install google-chrome-stable -y #Chrome

  # Outil web
  apt install pidgin deluge grsync subdownloader -y
  snap install discord 
  flatpak install --from https://flathub.org/repo/appstream/com.github.JannikHv.Gydl.flatpakref -y #Gydl
  wget https://repo.skype.com/latest/skypeforlinux-64.deb && dpkg -i skypeforlinux-64.deb ; apt install -fy ; rm skypeforlinux-64.deb #Skype
  
  # Multimedia
  apt install gnome-mpv quodlibet handbrake winff openshot -y
  flatpak install --from https://flathub.org/repo/appstream/de.haeckerfelix.gradio.flatpakref -y #Gradio

  # Graphisme/audio
  apt install sound-juicer pinta inkscape darktable audacity lame -y
  
  # Supplément bureautique
  apt install geary pdfmod -y
  
  # Utilitaires sup
  apt install keepassx ncdu screen openssh-server unrar -y
  
  ## Driver
  # Pour imprimante HP
  apt install hplip hplip-gui sane
 
  # nettoyage
  apt install -fy ; apt autoremove --purge -y ; apt clean ; clear
fi

# ----------------------------------------------------------------------------------------------------------------

## spécifique profil 5 : Raphael.B (Ubuntu 16.04/Unity)
if [ "$choixProfil" = "5" ] 
then
  #Alias Maj
  echo "alias maj='sudo apt update && sudo apt full-upgrade && sudo apt autoremove --purge -y && sudo apt clean ; clear'" >> /home/$SUDO_USER/.bashrc
 
  # Prise en compte de l'alias "maj"
  su $SUDO_USER -c "source ~/.bashrc"
  
  # Xcfa (X Convert File Audio) - mettre la ligne juste ci-dessous en commentaire si tu n'en n'a pas besoin
  apt install cdparanoia cd-discid xcfa -y #(cdparanoia et cd-discid sont des dépendances nécessaires pour xcfa)
  
  # Outils utiles 
  apt install unity-tweak-tool synaptic dmsetup diodon brasero xsane sane -y
  
  #rajouter plus tard : Shrew Soft VPN Access Manager (.ike)

  #Truecrypt
  add-apt-repository ppa:stefansundin/truecrypt -y ; apt update ; apt install truecrypt -y
  
  # Outil web
  apt install hexchat pidgin filezilla grsync -y
  
  # Teamviewer 8 pour assistance académique
  wget http://download.teamviewer.com/download/version_8x/teamviewer_linux.deb && dpkg -i teamviewer_linux.deb ; apt install -fy ; rm teamviewer_linux.deb 
 
  # Graphisme/Video
  apt install kazam pinta -y
  
  # Supplément bureautique
  apt install zim keepass2 xournal -y

  ## Pilote
  # Imprimante du travail (Kyocera Taskalfa 3511i)
  wget https://raw.githubusercontent.com/dane-lyon/fichier-de-config/master/Kyocera_taskalfa_3511i.PPD
  mv Kyocera_taskalfa_3511i.PPD /etc/cups/ppd/
  # Imprimante perso dcp5890cn (mfc?)
  wget http://download.brother.com/welcome/dlf006168/mfc5890cnlpr-1.1.2-2.i386.deb ; dpkg -i mfc5890cnlpr-1.1.2-2.i386.deb ; apt install -fy ; rm mfc5890cnlpr-1.1.2-2.i386.deb
  wget http://download.brother.com/welcome/dlf006642/brscan3-0.2.13-1.amd64.deb ; dpkg -i brscan3-0.2.13-1.amd64.deb ; apt install -fy ; rm brscan3-0.2.13-1.amd64.deb
  
  # Scratch 2 (l'installation ne pouvant pas être totalement automatisé, elle est placé à la fin)
  su $SUDO_USER -c "wget https://scratch.mit.edu/scratchr2/static/sa/Scratch-456.air ; chmod +x Scratch*"
  wget https://raw.githubusercontent.com/dane-lyon/fichier-de-config/master/adobe-air.sh ; chmod +x adobe-air.sh
  ./adobe-air.sh
  /home/$SUDO_USER/Adobe\ AIR\ Application\ Installer
  
  # nettoyage
  apt install -fy ; apt autoremove --purge -y ; apt clean ; clear
fi




s






echo "C'est fini ! Un reboot est nécessaire..."
read -p "Voulez-vous redémarrer immédiatement ? [O/n] " reboot
if [ "$reboot" = "o" ] || [ "$reboot" = "O" ]
then
    reboot
fi
