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

int prochainCoup (int sockIA, TCoupReq *reqCoup)
{
    TCase caseCible;
    caseCible.l = UN;
    caseCible.c = A;

    TPion pion;
    pion.coulPion = BLANC;
    pion.typePion = CYLINDRE;

    reqCoup->idRequest = COUP;
    reqCoup->numPartie = 1;
    reqCoup->estBloque = 0;
    reqCoup->pion = pion;
    reqCoup->posPion = caseCible;
    reqCoup->propCoup = VALID;

    return 0;
}

void afficherValidationCoup (TCoupRep repCoup, int joueur)
{
    switch (repCoup.validCoup)
    {
        case VALID:
        printf("joueur> coup VALIDE : ");
        break;

        case TIMEOUT:
        printf("joueur> coup TIMEOUT : ");
        break;

        case TRICHE:
        printf("joueur> coup TRICHE : ");
        break;

        default:
        printf("joueur> TValCoup inconnu : ");
        break;
    }

    switch (repCoup.propCoup)
    {
        case CONT:
        printf("partie CONTINUE");
        break;
        
        case GAGNE:
        printf("partie GAGNÉE");
        break;
        
        case NUL:
        printf("partie NULLE");
        break;
        
        case PERDU:
        printf("partie PERDUE");
        break;
        
        default:
        printf("TPropCoup inconnu");
        break;
    }

    if (!joueur)
    {
        printf(" (adversaire)\n");
    }
    else
    {
        printf("\n");
    }
}

int jouerPartie (int sockServeur, int sockIA, int commence)
{
    int err, joueur = commence, continuer = 1;
    TCoupReq reqCoup;
    TCoupRep repCoup;

    printf("joueur> commence ? %d\n", commence);

    while (continuer)
    {
        //Si c'est à nous de jouer.
        if (joueur)
        {
            //Calcul du prochain coup.
            err = prochainCoup(sockIA, &reqCoup);
            if (err < 0)
            {
                printf("joueur> erreur calcul prochain coup fdIA=%d\n", sockIA);
                return -1;
            }

            //Envoi du coup calculé.
            err = send(sockServeur, &reqCoup, sizeof(TCoupReq), 0);
            if (err <= 0)
            {
                perror("joueur> erreur send req coup");
                shutdownClose(sockServeur); //TODO select read + write pour gérer la réception du timeout
                return -2;
            }

            //Réception de la validation du coup.
            err = recv(sockServeur, &repCoup, sizeof(TCoupRep), 0);
            if (err <= 0)
            {
                perror("joueur> erreur recv rep coup");
                shutdownClose(sockServeur);
                return -3;
            }

            //Arrêt en cas d'erreur sur le coup joué.
            if (repCoup.err != ERR_OK)
            {
                printf("joueur> erreur sur le coup joué\n");
                shutdownClose(sockServeur);
                return -4;//TODO: improve
            }

            afficherValidationCoup(repCoup, joueur);

            //Fin de partie le cas échéant.
            if (repCoup.propCoup != CONT)
            {
                continuer = 0;
            }
            //Sinon c'est à l'adversaire de jouer.
            else
            {
                joueur = 0;
            }
        }
        //Sinon c'est à l'adversaire de jouer.
        else
        {
            //Réception de la validation du coup adverse.
            err = recv(sockServeur, &repCoup, sizeof(TCoupRep), 0);
            if (err <= 0)
            {
                perror("joueur> erreur recv rep coup adverse");
                shutdownClose(sockServeur);
                return -5;
            }

            afficherValidationCoup(repCoup, joueur);

            //Fin de partie le cas échéant.
            if (repCoup.propCoup != CONT)
            {
                continuer = 0;
            }
            //Sinon c'est à nous de jouer.
            else
            {
                joueur = 1;

                //Réception du coup adverse.
                err = recv(sockServeur, &reqCoup, sizeof(TCoupReq), 0);
                if (err <= 0)
                {
                    perror("joueur> erreur recv req coup adverse");
                    shutdownClose(sockServeur);
                    return -6;
                }
                //TODO send coup à IA
            }
        }
    }

    return 0;
}

int main (int argc, char **argv) 
{
    int sock,
        sockIA,
        portDest,
        portIA,
        err;
    char* nomMachineDest;
    TPartieReq reqPartie;
    TPartieRep repPartie;

    //Vérification des arguments.
    if (argc != 6) 
    {
        printf("joueur> usage : %s <nomMachineDest> <portDest> <nomJoueur> <couleurPion> <portIA>\n", argv[0]);
        return -1;
    }

    //Préparation de la requête de partie.
    nomMachineDest = argv[1];
    portDest = atoi(argv[2]);
    portIA = atoi(argv[5]);
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
        shutdownClose(sock);
        return -4;
    }

    //Réception de la réponse du serveur.
    err = recv(sock, &repPartie, sizeof(TPartieRep), 0);
    if (err <= 0) 
    {
        perror("joueur> erreur recv partie");
        shutdownClose(sock);
        return -5;
    }
    printf("joueur> VS %s fd=%d\n", repPartie.nomAdvers, sock);

    //Vérification de la réponse.
    if (repPartie.err == ERR_TYP)//TODO refactor
    {
        printf("joueur> erreur type de requête\n");
        shutdownClose(sock);
        return -6;
    }
    else if (repPartie.err == ERR_PARTIE)
    {
        printf("joueur> erreur création partie, réessayer\n");
        shutdownClose(sock);
        return -7;
    }
    else if (repPartie.err != ERR_OK)
    {
        printf("joueur> autre erreur reçue\n");
        shutdownClose(sock);
        return -8;
    }

    //Changement de couleur si nécessaire.
    if (repPartie.validCoulPion == KO)
    {
        if (reqPartie.coulPion == NOIR) 
        {
            reqPartie.coulPion = BLANC;
            printf("joueur> BLANC fd=%d\n", sock);
        }
        else
        {
            reqPartie.coulPion = NOIR;
            printf("joueur> NOIR fd=%d\n", sock);
        }
    }

    //Connexion au moteur IA.
    sockIA = socketClient("127.0.0.1", portIA);
    if (sockIA < 0)
    {
        perror("joueur> erreur creation socket IA");
        return -9;
    }

    printf("joueur> début jeu\n");

    //Première manche.
    err = jouerPartie(sock, sockIA, (reqPartie.coulPion == BLANC ? 1 : 0));
    if (err < 0)
    {
        printf("joueur> erreur 1ere partie\n");
        return -10;
    }

    //Première manche.
    err = jouerPartie(sock, sockIA, (reqPartie.coulPion == BLANC ? 0 : 1));
    if (err < 0)
    {
        printf("joueur> erreur 2eme partie\n");
        return -11;
    }

    shutdownCloseBoth(sock, sockIA);

    return 0;
}