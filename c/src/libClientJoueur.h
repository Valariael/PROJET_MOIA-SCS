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

int verifCodeRep (int sock);
int recvIntFromJava (int sock, int *data);
int prochainCoup (int sockIA, TCoupReq *reqCoup, TCoul couleur, int num);
int adversaireCoup(int sockIA, TCoupReq *reqCoup);
void afficherValidationCoup (TCoupRep repCoup, int joueur);
int jouerPartie (int sockServeur, int commence, TCoul couleur, int num);
int jouerPartieIA (int sockServeur, int sockIA, int commence, TCoul couleur, int num);

#endif