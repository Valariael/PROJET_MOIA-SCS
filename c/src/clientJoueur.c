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
//TODO Gérer le timeout de 5 secondes
//recevoir le numéro de partie

//TODO shutDownCloseBoth après chaque erreur appel fct
int main (int argc, char **argv) 
{
    int sock,
        sockIA,
        portDest,
        portIA,
        err,
        idJoueur = rand() % 100,
        termine = 6,
        num = 1;//TODO projet fini -> enlver affichages
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
        perror("joueur> erreur send partie");
        shutdownClose(sock);
        return -4;
    }

    //Réception de la réponse du serveur.
    err = verifCodeRep(sock);
    if (err == 0) err = recv(sock, &repPartie, sizeof(TPartieRep), 0);
    if (err <= 0) 
    {
        perror("joueur> erreur recv partie");
        shutdownClose(sock);
        return -5;
    }
    printf("joueur> %s VS %s fd=%d\n", reqPartie.nomJoueur, repPartie.nomAdvers, sock);

    //Changement de couleur si nécessaire.
    if (repPartie.validCoulPion == KO)
    {
        if (reqPartie.coulPion == NOIR) 
        {
            reqPartie.coulPion = BLANC;
            printf("joueur> BLANC id=%d\n", idJoueur);
        }
        else
        {
            reqPartie.coulPion = NOIR;
            printf("joueur> NOIR id=%d\n", idJoueur);
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

        printf("joueur> début jeu IA\n");

        //Première manche.
        err = jouerPartieIA(sock, sockIA, (reqPartie.coulPion == BLANC ? 1 : 0), reqPartie.coulPion, idJoueur, num);
        if (err < 0)
        {
            printf("joueur> erreur 1ere partie\n");
            shutdownCloseBoth(sock,sockIA);
            return -10;
        }
        num++;
        //Deuxième manche.
        err = jouerPartieIA(sock, sockIA, (reqPartie.coulPion == BLANC ? 0 : 1), reqPartie.coulPion, idJoueur, num);
        if (err < 0)
        {
            printf("joueur> erreur 2eme partie\n");
            shutdownCloseBoth(sock,sockIA);
            return -11;
        }
        
        err = send(sockIA,&termine,sizeof(int),0);
        if (err <= 0)
        {
            printf("joueur> erreur terminaison partie IA\n");
            return -12;
        }
        shutdownCloseBoth(sock, sockIA);
    }
    else
    {
        //Choix des coups manuel
        printf("joueur> début jeu manuel\n");

        //Première manche.
        err = jouerPartie(sock, (reqPartie.coulPion == BLANC ? 1 : 0), reqPartie.coulPion, idJoueur,num);
        if (err < 0)
        {
            printf("joueur> erreur 1ere partie\n");
            shutdownClose(sock);
            return -13;
        }
        num++;
        //Deuxième manche.
        err = jouerPartie(sock, (reqPartie.coulPion == BLANC ? 0 : 1), reqPartie.coulPion, idJoueur, num);
        if (err < 0)
        {
            printf("joueur> erreur 2eme partie\n");
            shutdownClose(sock);
            return -14;
        }

        shutdownClose(sock);
    }

    return 0;
}