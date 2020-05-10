#ifndef _PROTO_CLIENT_H
#define _PROTO_CLIENT_H

#include "protocolQuantik.h"

typedef enum { 
    CODE_OK,
    CODE_NV_PARTIE_BLANC, 
    CODE_NV_PARTIE_NOIR, 
    CODE_COUP_SELF, 
    CODE_COUP_ADV 
} CodeRepIA;

//Met à jour les compteurs de victoire, défaite et match nul suivant la propriété du coup et le joueur courant
void miseAJourCompteurs(int* victoires, int* defaites, int* nuls, int proprieteCoup, int isJoueur);
//Vérifie que le code d'erreur soit ERR_OK lors de la réception d'une réponse
int verifCodeRep (int sock);
//Rcéeptionne correctement un entier envoyé par un programme Java
int recvIntFromJava (int sock, int *data);
//Rcéeptionne le prochain coup à jouer envoyé par le moteur d'IA
int prochainCoup (int sockIA, TCoupReq *reqCoup, TCoul couleur, int num);
//Envoie le coup de l'adversaire au moteur d'IA
int adversaireCoup(int sockIA, TCoupReq *reqCoup);
//Affiche la propriété du coup et son impact sur la partie en cours
void afficherValidationCoup (TCoupRep repCoup, int joueur);
//Permet de jouer une partie de Quantik en mode manuel, par entrée clavier de l'utilisateur
int jouerPartie (int sockServeur, int commence, TCoul couleur, int num, int* victoires, int* defaites, int* nuls);
//Joue une partie avec le moteur d'IA
int jouerPartieIA (int sockServeur, int sockIA, int commence, TCoul couleur, int num, int* victoires, int* defaites, int* nuls);

#endif