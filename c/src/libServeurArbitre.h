#ifndef _PROTO_SERVEUR_H
#define _PROTO_SERVEUR_H

#include "protocolQuantik.h"

//Fonction utilisée par le gestionnaire de signal pour éviter les "zombies"
void sigchildHandler(int signum);
//Vérifie que le type de requête reçue soit bien celui attendu, envoie une réponse ERR_TYP dans le cas contraire
int verifIdRequete (int *sockJoueur, int idAttendu);
//Accepte une demande de partie de la part d'un joueur
void connecteJoueur (int *sockJoueur, int sockConnexion, TPartieReq *reqPartie);
//Envoie la réponse à la demande de partie
int ackJoueursConnectes (int *sockJoueur, int *sockAutreJoueur, TPartieRep *repPartie, TPartieRep *repPartieAutre);
//Accepte une paire de joueurs valides avant le lancement d'une partie
int paireJoueurValides (int *sockJoueur1, int *sockJoueur2, int sockConnexion);
//Envoie la réponse à un coup aux deux joueurs
int envoyerRepCoup (int sockJoueur, int sockAutreJoueur, TCoupRep *repCoup);
//Effectue tous les traitements pour un coup reçu
int traiterCoup (int sockJoueur, int sockAutreJoueur, int sockJoueurCourant, int numJoueur);
//Joue une partie complète avec la paire de joueurs
int jouerPartie (int sockJoueur1, int sockJoueur2);

#endif