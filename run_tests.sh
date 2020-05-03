#!/bin/bash

#sh run_tests.sh

clear
echo "Compilation des tests client et serveur."
cd c/tests
make
err=$?
if [ $err -ne "0" ]; then
	echo "Erreur à la des tests client et serveur !"
	exit -1
fi
./../out/testsLibClientJoueur
echo "Tests libClientJoueur lancés."