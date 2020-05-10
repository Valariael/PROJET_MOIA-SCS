#!/bin/bash

#sh autoPlay.sh portServeur portIAJoueur1 portIAJoueur2 [*]
#n'importe quoi en 4ème paramètre pour exécuter avec le binaire de serveur fourni

if [ $# -ne 5 ]; then
	if [ $# -ne 6 ]; then
		echo "Usage : ./autoPlay.sh <portServeur> <portIAJoueur1> <portIAJoueur2> <IA J1> <IA J2> [*]"
		echo "Types d'IA : 1 = call heuristique, 2 = miroir, 3 = meilleur ratio V/D et cases bloquées, 4 = coup par défaut, 5 = aléatoire"
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
mkdir ../out
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
java -cp ".:/usr/lib/swi-prolog/lib/jpl.jar" src.MoteurIA $2 $4 &
echo "Moteur IA joueur 1 lancé."
java -cp ".:/usr/lib/swi-prolog/lib/jpl.jar" src.MoteurIA $3 $5 &
echo "Moteur IA joueur 2 lancé."

echo "Compilation serveur/client."
cd ../../c/src
mkdir ../out
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
