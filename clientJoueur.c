#include <stdio.h>
#include <stdlib.h>
#include <netinet/ip.h>
#include <unistd.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <string.h>
#include "libSockets.h"
#include "protocolQuantik.h"
#include "validation.h"

int main(int argc, char **argv) 
{
    int sock,
        portDest,
        err;
    char* nomMachineDest;
    TPartieReq reqPartie;
    TPartieRep repPartie;

    //Vérification des arguments.
    if (argc != 5) 
    {
        printf("joueur> usage : %s <nomMachineDest> <portDest> <nomJoueur> <couleurPion>\n", argv[0]);
        return -1;
    }

    //Préparation de la requête de partie.
    nomMachineDest = argv[1];
    portDest = atoi(argv[2]);
    reqPartie.idReq = PARTIE;
    strcpy(reqPartie.nomJoueur, argv[3]);
    if (strcmp(argv[4], "B") == 0) 
    {
        reqPartie.coulPion = BLANC;
    } 
    else if (strcmp(argv[4], "N") == 0) 
    {
        reqPartie.coulPion = NOIR;
    } 
    else 
    {
        printf("joueur> usage : %s <nomMachineDest> <portDest> <nomJoueur> <couleurPion>\n", argv[0]);
        printf("joueur> couleur incorrecte : B (blanc) ou N (noir)\n");
        return -2;
    }

    //Création du socket de communication.
    sock = socketClient(nomMachineDest, portDest);
    if (sock < 0) 
    {
        perror("joueur> erreur creation socket client");
        return -3;
    }

    //Envoi de la demande de partie.
    err = send(sock, &reqPartie, sizeof(TPartieReq), 0);
    if (err <= 0)
    {
        perror("joueur> erreur send partie");
        shutdown(sock, SHUT_RDWR);
        close(sock);
        return -4;
    }

    //Réception de la réponse du serveur.
    err = recv(sock, &repPartie, sizeof(TPartieRep), 0);
    if (err <= 0) 
    {
        perror("joueur> erreur recv partie");
        shutdown(sock, SHUT_RDWR);
        close(sock);
        return -5;
    }

    //Vérification de la réponse.
    if (repPartie.err == ERR_TYP)
    {
        printf("joueur> erreur type de requête\n");
        shutdown(sock, SHUT_RDWR);
        close(sock);
        return -6;
    }
    else if (repPartie.err == ERR_PARTIE)
    {
        printf("joueur> erreur création partie, réessayer\n");
        shutdown(sock, SHUT_RDWR);
        close(sock);
        return -7;
    }
    else if (repPartie.err != ERR_OK)
    {
        printf("joueur> autre erreur reçue\n");
        shutdown(sock, SHUT_RDWR);
        close(sock);
        return -8;
    }

    //Changement de couleur si nécessaire.
    if (repPartie.validCoulPion == KO) 
    {
        if (reqPartie.coulPion == NOIR) reqPartie.coulPion = BLANC;
        if (reqPartie.coulPion == BLANC) reqPartie.coulPion = NOIR;
    }

    printf("joueur> début jeu\n");
    //jeu

    shutdown(sock, SHUT_RDWR);
    close(sock);

    return 0;
}