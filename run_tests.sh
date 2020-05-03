#!/bin/bash

#sh run_tests.sh

clear
echo "Compilation serveur/client."
cd c/src
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
./testsLibClientJoueur
echo "Tests libClientJoueur terminés."
gcov -abcfu libClientJoueur.so