#!/bin/bash

#sh cleanOutput.sh

echo "Nettoyage des fichiers produits."

rm -v c/tests/*.gcov
rm -v c/tests/*.gcda
rm -v c/tests/*.gcno
rm -v c/tests/*.so
rm -v c/out/*
cd c/tests
rm -v testsLibServeurArbitre testsLibClientJoueur
cd ../..
rm -vr java/out/*
rm -v java/tests/*.exec
rm -vr java/tests/coverageReport

clear
echo "Nettoyage des fichiers produits terminé."