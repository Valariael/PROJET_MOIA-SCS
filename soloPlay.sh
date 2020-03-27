#!/bin/bash

#sh soloPlay.sh portServeur portIA

if [ $# -ne 2 ]; then
    echo "Usage : ./soloPlay.sh <portServeur> <portIA>"
    exit -1
fi

clear
echo "Compilation moteur IA."
cd java
make
err=$?
if [ $err -ne "0" ]; then
	echo "Erreur à la compilation du moteur IA !"
	exit -1
fi
java MoteurIA $2 &
echo "Moteur IA lancé."
cd ..

echo "Compilation serveur/client."
make
err=$?
if [ $err -ne "0" ]; then
	echo "Erreur à la compilation du serveur/client !"
	exit -1
fi
./serveurArbitre $1 &
echo "Serveur lancé."

./clientJoueur 127.0.0.1 $1 noir N $2 &
echo "Client noir lancé."

./clientJoueur 127.0.0.1 $1 blanc N $2 &
echo "Client blanc lancé."
