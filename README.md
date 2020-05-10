# PROJET MOIA-SCS

## Usage

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
sh soloPlay.sh portServeur portIAJoueur1 portIAJoueur2 typeIAJ1 typeIAJ2 `[*]`
```
Les types d'IA sont les suivants : 
1 : parcours heuristique amélioré
2 : en miroir de l'adversaire ou meilleur ratio V/D et cases bloquées
3 : meilleur ratio V/D et cases bloquées
4 : coup par défaut
5 : aléatoire