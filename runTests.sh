#!/bin/bash

#sh runTests.sh

clear
echo "Compilation serveur/client."
cd c/src
mkdir ../out
make
err=$?
if [ $err -ne "0" ]; then
	echo "Erreur à la compilation du serveur/client !"
	exit -1
fi
cd ..

echo "Compilation des tests client et serveur pour coverage."
cd tests
make coverage
err=$?
if [ $err -ne "0" ]; then
	echo "Erreur à la compilation des tests client et serveur pour coverage !"
	exit -2
fi

if [[ $LD_LIBRARY_PATH != *"$(pwd)"* ]]; then
	export LD_LIBRARY_PATH=$(pwd):${LD_LIBRARY_PATH}
fi
echo "Exécution tests libClientJoueur."
./../out/clientTest &
./testsLibClientJoueur < testData_jouerPartie.txt
echo "Tests libClientJoueur terminés."
gcov -abcfu libClientJoueur.so

echo "Exécution tests libServeurArbitre."
./../out/serveurTest &
./testsLibServeurArbitre
echo "Tests libServeurArbitre terminés."
gcov -abcfu libServeurArbitre.so

echo "Compilation MoteurIA."
cd ../../java/src
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
	exit -3
fi

echo "Compilation des tests MoteurIA pour coverage."
cd ../tests
make
