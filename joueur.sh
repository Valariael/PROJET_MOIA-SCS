#!/bin/bash

#sh joueur.sh hostServeur portServeur nomJoueur couleur portIA

clear
echo "Compilation moteur IA."
cd java
make
err=$?
if [ $err -ne "0" ]; then
	echo "Erreur à la compilation du moteur IA !"
	exit -1
fi
java MoteurIA $5 &
cd ..

cd c
echo "Compilation joueur."
make
err=$?
if [ $err -ne "0" ]; then
	echo "Erreur à la compilation du joueur !"
	exit -1
fi
./clientJoueur $1 $2 $3 $4 $5 &
