#!/bin/bash

#sh joeur.sh hostServeur portServeur nomJoueur [*]

if [ $# -ne 3 ]; then
    if [ $# -ne 4 ]; then
    echo "Usage : ./soloPlay.sh <hostServeur> <portServeur> <nomJoueur>[<portIA>]"
    exit -1
    else 
        portIA=true
    fi
else portIA=false
fi
clear
cd java/src
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
cd ../out
if [ "$portIA" = false ]; then
java -cp ".:/usr/lib/swi-prolog/lib/jpl.jar" src.MoteurIA 6666 1 &
echo "Moteur IA de $3 lancé."
else
java -cp ".:/usr/lib/swi-prolog/lib/jpl.jar" src.MoteurIA $4 1 &
echo "Moteur IA de $3 lancé."
fi
cd ../../c/src
make
err=$?
if [ $err -ne "0" ]; then
	echo "Erreur à la compilation du serveur/client !"
	exit -1
fi
cd ../out
if [ "$portIA" = false ]; then
./clientJoueur $1 $2 $3 N 6666 &
echo "Client blanc lancé."
else 
./clientJoueur $1 $2 $3 N $4 &
echo "Client blanc lancé."
fi