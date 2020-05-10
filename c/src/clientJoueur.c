#include <stdio.h>
#include <stdlib.h>
#include <netinet/ip.h>
#include <unistd.h>
#include <sys/select.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <string.h>
#include "libSockets.h"
#include "protocolQuantik.h"
#include "libClientJoueur.h"

int main (int argc, char **argv) 
{
    int sock,
        sockIA,
        portDest,
        portIA,
        err,
        termine = 6,
        num = 1,
        victoires = 0,
        defaites = 0,
        nuls = 0;
    char* nomMachineDest;
    TPartieReq reqPartie;
    TPartieRep repPartie;

    //Vérification des arguments.
    if (argc == 5) 
    {
        printf("joueur> mode manuel\n");
        portIA = -1;
    }
    else if (argc == 6)
    {
        printf("joueur> mode IA\n");
        portIA = atoi(argv[5]);
    }
    else
    {
        printf("joueur> usage : %s <nomMachineDest> <portDest> <nomJoueur> <couleurPion> [<portIA>]\n", argv[0]);
        return -1;
    }

    //Préparation de la requête de partie.
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
        printf("joueur> usage : %s <nomMachineDest> <portDest> <nomJoueur> <couleurPion> [<portIA>]\n", argv[0]);
        printf("joueur> couleurPion est B (blanc) ou N (noir)\n");
        return -2;
    }
    nomMachineDest = argv[1];
    portDest = atoi(argv[2]);
    reqPartie.idReq = PARTIE;
    strcpy(reqPartie.nomJoueur, argv[3]);

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
        perror("joueur> erreur send requete partie");
        shutdownClose(sock);
        return -4;
    }

    //Réception de la réponse du serveur.
    err = verifCodeRep(sock);
    if (err == 0) err = recv(sock, &repPartie, sizeof(TPartieRep), 0);
    if (err <= 0) 
    {
        perror("joueur> erreur recv reponse partie");
        shutdownClose(sock);
        return -5;
    }
    printf("joueur> %s VS %s\n", reqPartie.nomJoueur, repPartie.nomAdvers);

    //Changement de couleur si nécessaire.
    if (repPartie.validCoulPion == KO)
    {
        if (reqPartie.coulPion == NOIR) 
        {
            reqPartie.coulPion = BLANC;
            printf("joueur> couleur BLANC\n");
        }
        else
        {
            reqPartie.coulPion = NOIR;
            printf("joueur> couleur NOIR\n");
        }
    }

    if (portIA != -1)
    {
        //Connexion au moteur IA.
        sockIA = socketClient("127.0.0.1", portIA);
        if (sockIA < 0)
        {
            perror("joueur> erreur creation socket IA");
            shutdownClose(sock);
            return -9;
        }

        printf("joueur> debut jeu IA\n");

        //Première manche.
        err = jouerPartieIA(sock, sockIA, (reqPartie.coulPion == BLANC ? 1 : 0), reqPartie.coulPion, num, &victoires, &defaites, &nuls);
        if (err < 0)
        {
            printf("joueur> erreur 1ere partie IA\n");
            shutdownCloseBoth(sock,sockIA);
            return -10;
        }
        num++;
        //Deuxième manche.
        err = jouerPartieIA(sock, sockIA, (reqPartie.coulPion == BLANC ? 0 : 1), reqPartie.coulPion, num, &victoires, &defaites, &nuls);
        if (err < 0)
        {
            printf("joueur> erreur 2eme partie IA\n");
            shutdownCloseBoth(sock,sockIA);
            return -11;
        }
        
        err = send(sockIA,&termine,sizeof(int),0);
        if (err <= 0)
        {
            printf("joueur> erreur terminaison IA\n");
            return -12;
        }
        shutdownCloseBoth(sock, sockIA);
    }
    else
    {
        //Choix des coups manuel
        printf("joueur> debut jeu manuel\n");

        //Première manche.
        err = jouerPartie(sock, (reqPartie.coulPion == BLANC ? 1 : 0), reqPartie.coulPion, num, &victoires, &defaites, &nuls);
        if (err < 0)
        {
            printf("joueur> erreur 1ere partie\n");
            shutdownClose(sock);
            return -13;
        }
        num++;
        //Deuxième manche.
        err = jouerPartie(sock, (reqPartie.coulPion == BLANC ? 0 : 1), reqPartie.coulPion, num, &victoires, &defaites, &nuls);
        if (err < 0)
        {
            printf("joueur> erreur 2eme partie\n");
            shutdownClose(sock);
            return -14;
        }

        shutdownClose(sock);
    }

    printf("----- Résultat final -----\n");
    printf("Victoires : %d\n", victoires);
    printf("Défaites : %d\n", defaites);
    printf("Matchs nuls : %d\n", nuls);

    return 0;
}