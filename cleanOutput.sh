#!/bin/bash

#sh cleanOutput.sh

echo "Nettoyage des fichiers produits."

rm -v c/tests/*.gcov
rm -v c/tests/*.gcda
rm -v c/tests/*.gcno
rm -v c/tests/*.so
rm -v c/out/*
cd c/tests
rm -v testsLibServeurArbitre testsLibClientJoueur clientTest serveurTest

clear
echo "Nettoyage des fichiers produits terminé."