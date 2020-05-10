# PROJET MOIA-SCS

## Usage

La plupart de ces scripts utilisant la commande mkdir, il peut être nécessaire de faire un chmod pour lui donner les permissions.

Pour lancer un joueur : 
```bash
sh joueur.sh hostServeur portServeur nomJoueur `[portIA]`
```
(le port du moteur IA est défini à 900 par défaut)

Pour lancer les tests :
```bash
sh runTests.sh
```

Pour lancer une partie de manière automatique entre deux IAs :
```bash
sh autoPlay.sh portServeur portIAJoueur1 portIAJoueur2 typeIAJ1 typeIAJ2 `[*]`
```
Les types d'IA sont les suivants : 
 - 1 : parcours heuristique amélioré
 - 2 : en miroir de l'adversaire ou meilleur ratio V/D et cases bloquées
 - 3 : meilleur ratio V/D et cases bloquées
 - 4 : coup par défaut
 - 5 : aléatoire
Le dernier paramètre peut être n'importe quoi, celui-ci déclenche l'utilisation du binaire de serveur fourni à la place de celui codé.

Pour supprimer tous les fichiers supplémentaires créés :
```bash
sh cleanOutput.sh
```

Ce projet utilise plusieurs bibliothèques externes :
 - [jacoco],
 - [junit] et sa dépendance hamcrest,
 - [minunit].

Dépôt github : 
https://github.com/Valariael/PROJET_MOIA-SCS.git

[jacoco]: https://www.jacoco.org/jacoco
[junit]: https://junit.org/junit5/
[minunit]: https://github.com/siu/minunit