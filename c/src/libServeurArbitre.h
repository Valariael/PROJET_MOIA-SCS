#ifndef _PROTO_SERVEUR_H
#define _PROTO_SERVEUR_H

#include "protocolQuantik.h"

int verifIdRequete (int *sockJoueur, int idAttendu);
void connecteJoueur (int *sockJoueur, int sockConnexion, TPartieReq *reqPartie);
int ackJoueursConnectes (int *sockJoueur, int *sockAutreJoueur, TPartieRep *repPartie, TPartieRep *repPartieAutre);
int paireJoueurValides (int *sockJoueur1, int *sockJoueur2, int sockConnexion);
int envoyerRepCoup (int sockJoueur, int sockAutreJoueur, TCoupRep *repCoup);
int traiterCoup (int sockJoueur, int sockAutreJoueur, int sockJoueurCourant, int numJoueur);
int jouerPartie (int sockJoueur1, int sockJoueur2);

#endif