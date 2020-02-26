#!/bin/bash

clear
echo "Compilation arbitre et joueur."
make
err=$?
if [ $err -ne "0" ]; then
	echo "Erreur à la compilation !"
	exit -1
fi
echo "Lancement du script de test pour un arbitre et deux joueurs."
./serveurArbitre 8080 &
echo "Arbitre lancé."
./clientJoueur 127.0.0.1 8080 pseudo1 B &
echo "Joueur 1 lancé."
./clientJoueur 127.0.0.1 8080 pseudo2 B &
echo "Joueur 2 lancé."