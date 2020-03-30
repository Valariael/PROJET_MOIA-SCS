#!/bin/bash

#sh soloPlay.sh portServeur portIAJoueur1 portIAJoueur2

if [ $# -ne 3 ]; then
	echo "Usage : 3./soloPlay.sh <portServeur> <portIAJoueur1> <portIAJoueur2>"
	exit -1
fi

clear
echo "Compilation moteur IA."
cd java
if [[ $LD_PRELOAD != *"libswipl.so"* ]]; then
	export LD_PRELOAD=libswipl.so:${LD_PRELOAD}
fi
if [[ $LD_LIBRARY_PATH != *"/usr/lib/swi-prolog/lib/amd64/"* ]]; then
	export LD_LIBRARY_PATH=/usr/lib/swi-prolog/lib/amd64/:${LD_LIBRARY_PATH}
fi
if [[ $CLASSPATH != *"/usr/lib/swi-prolog/lib/jpl.jar"* ]]; then
	export CLASSPATH=/usr/lib/swi-prolog/lib/jpl.jar:${CLASSPATH}
fi
make
err=$?
if [ $err -ne "0" ]; then
	echo "Erreur à la compilation du moteur IA !"
	exit -1
fi
java MoteurIA $2 &
echo "Moteur IA joueur 1 lancé."
java MoteurIA $3 &
echo "Moteur IA joueur 2 lancé."
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

./clientJoueur 127.0.0.1 $1 blanc N $3 &
echo "Client blanc lancé."
