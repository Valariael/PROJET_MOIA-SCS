#!/bin/bash

#sh soloPlay.sh portServeur portIAJoueur1 portIAJoueur2 [*]
#n'importe quoi en 4ème paramètre pour exécuter avec le binaire de serveur fourni

if [ $# -ne 5 ]; then
	if [ $# -ne 6 ]; then
		echo "Usage : ./soloPlay.sh <portServeur> <portIAJoueur1> <portIAJoueur2> <IA J1> <IA J2> [*]"
		echo "Types d'IA : 1 = call heuristique, 2= miroir, 3 = meilleur ratio, 4 = coup normal, 5 heuristique 'seulement'"
		exit -1
	else
		binaireFourni=true
	fi
else
	binaireFourni=false
fi

clear
echo "Compilation moteur IA."
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
java MoteurIA $2 $4 &
echo "Moteur IA joueur 1 lancé."
java MoteurIA $3 $5 &
echo "Moteur IA joueur 2 lancé."

echo "Compilation serveur/client."
cd ../../c/src
make
err=$?
if [ $err -ne "0" ]; then
	echo "Erreur à la compilation du serveur/client !"
	exit -1
fi
cd ..
if [ "$binaireFourni" = true ]; then
	./src/quantikServeur $1 &
else
	./out/serveurArbitre $1 &
fi
echo "Serveur lancé."

./out/clientJoueur 127.0.0.1 $1 noir N $2 &
echo "Client noir lancé."

./out/clientJoueur 127.0.0.1 $1 blanc N $3 &
echo "Client blanc lancé."
