#!/bin/bash

#sh joueur.sh hostServeur portServeur nomJoueur [<portIA>]

if [ $# -ne 3 ]; then
    if [ $# -ne 4 ]; then
	    echo "Usage : ./joueur.sh <hostServeur> <portServeur> <nomJoueur> [<portIA>]"
	    exit -1
    else 
        portIA=true
    fi
else 
	portIA=false
fi
clear
cd java/src
mdir ../out
if [[ $LD_PRELOAD != *"/usr/lib/swi-prolog/lib/x86_64-linux/libswipl.so"* ]]; then
	export LD_PRELOAD=/usr/lib/swi-prolog/lib/x86_64-linux/libswipl.so:${LD_PRELOAD}
fi
if [[ $LD_LIBRARY_PATH != *"/usr/lib/swi-prolog/lib/x86_64-linux/"* ]]; then
	export LD_LIBRARY_PATH=/usr/lib/swi-prolog/lib/x86_64-linux/:${LD_LIBRARY_PATH}
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
cd ../out
if [ "$portIA" = false ]; then
	java -cp ".:/usr/lib/swi-prolog/lib/jpl.jar" src.MoteurIA 9000 1 &
	echo "Moteur IA de $3 lancé."
else
	java -cp ".:/usr/lib/swi-prolog/lib/jpl.jar" src.MoteurIA $4 1 &
	echo "Moteur IA de $3 lancé."
fi
cd ../../c/src
mkdir ../out
make
err=$?
if [ $err -ne "0" ]; then
	echo "Erreur à la compilation du serveur/client !"
	exit -1
fi
cd ../out
if [ "$portIA" = false ]; then
	./clientJoueur $1 $2 $3 N 9000 &
	echo "Client blanc lancé."
else 
	./clientJoueur $1 $2 $3 N $4 &
	echo "Client blanc lancé."
fi