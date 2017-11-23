#!/bin/bash

if [ "$UID" -ne "0" ]
then
  echo "Il faut etre root pour executer ce script ==> sudo ./script.sh"
  exit 
fi 

echo "Profil à utiliser :
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




fi

##################################
# Commun à tous - base Debian 9
##################################
if [ "$choixProfil" = "2" ] || [ "$choixProfil" = "6" ] || [ "$choixProfil" = "11" ]
then




fi



##################################
# Commun à tous - base Arch
##################################
if [ "$choixProfil" = "3" ] || [ "$choixProfil" = "12" ]
then




fi

##################################
# Supplément spécifique suivant profil
##################################

## spécifique profil 1 sur Ubuntu avec Gnome Shell
if [ "$choixProfil" = "1" ] 
then


fi

## spécifique profil 2 sur Debian avec Xfce
if [ "$choixProfil" = "2" ] 
then


fi

## spécifique profil 3 sur Arch avec Xfce
if [ "$choixProfil" = "3" ] 
then


fi

## spécifique profil 4 : plus tard
if [ "$choixProfil" = "4" ] 
then


fi


## spécifique profil 5 : Ubuntu avec Gnome Shell
if [ "$choixProfil" = "5" ] 
then


fi

## spécifique profil 6 : Debian avec Xfce
if [ "$choixProfil" = "6" ] 
then


fi


## spécifique profil 7 : Ubuntu Mate
if [ "$choixProfil" = "7" ] 
then


fi

echo "Pour prendre en compte tous les changements, il faut maintenant redémarrer !"
read -p "Voulez-vous redémarrer immédiatement ? [o/n] " reboot
if [ "$reboot" = "o" ] || [ "$reboot" = "O" ]
then
    reboot
fi
