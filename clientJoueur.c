#include <stdio.h>
#include <stdlib.h>
#include <netinet/ip.h>
#include <unistd.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <string.h>
#include "libSockets.h"
#include "protocolQuantik.h"
#include "validation.h"

typedef enum { 
    CODE_OK,
    CODE_NV_PARTIE_BLANC, 
    CODE_NV_PARTIE_NOIR, 
    CODE_COUP_SELF, 
    CODE_COUP_ADV 
} CodeRepIA;

int recvIntFromJava(int sock, int *data)
{
    int err = 0;

    while(err < 4) 
    {
        err = recv(sock, data, sizeof(int), MSG_PEEK);
        if (err < 0)
        {
            perror("joueur> erreur recv Java MSG_PEEK");
            shutdownClose(sock);
            return -1;
        }
    }
    err = recv(sock, data, sizeof(int), 0);
    if (err <= 0)
    {
        perror("joueur> erreur recv Java");
        shutdownClose(sock);
        return -2;
    }
    *data = ntohl(*data);

    return 0;
}

int prochainCoup (int sockIA, TCoupReq *reqCoup, TCoul couleur)
{
    int err, data;
    TCase caseCible;
    TPion pion;

    //Envoi du signal et réception du prochain coup à jouer.
    data = htonl(CODE_COUP_SELF);
    err = send(sockIA, &data, sizeof(int), 0);
    if (err <= 0)
    {
        perror("joueur> erreur send code req coup self IA");
        shutdownClose(sockIA);
        return -1;
    }

    err = recvIntFromJava(sockIA, &data);
    if (err < 0)
    {
        printf("joueur> erreur recv estBloque IA");
        return -2;
    }
    reqCoup->estBloque = data;

    err = recvIntFromJava(sockIA, &data);
    if (err < 0)
    {
        printf("joueur> erreur recv typePion IA");
        return -4;
    }
    pion.typePion = data;
    pion.coulPion = couleur;

    err = recvIntFromJava(sockIA, &data);
    if (err < 0)
    {
        printf("joueur> erreur recv ligne IA");
        return -5;
    }
    caseCible.l = data;

    err = recvIntFromJava(sockIA, &data);
    if (err < 0)
    {
        printf("joueur> erreur recv colonne IA");
        return -6;
    }
    caseCible.c = data;

    err = recvIntFromJava(sockIA, &data);
    if (err < 0)
    {
        printf("joueur> erreur recv prop coup IA");
        return -7;
    }
    reqCoup->propCoup = data;

    reqCoup->idRequest = COUP;
    reqCoup->numPartie = 1;//TODO
    reqCoup->pion = pion;
    reqCoup->posPion = caseCible;

    return 0;
}

int adversaireCoup(int sockIA, TCoupReq *reqCoup)
{
    int err, data;
    TCase caseCible = reqCoup->posPion;
    TPion pion = reqCoup->pion;

    //Envoi du signal et du coup de l'adversaire.
    data = htonl(CODE_COUP_ADV);
    err = send(sockIA, &data, sizeof(int), 0);
    if (err <= 0)
    {
        perror("joueur> erreur send code req coup adv IA");
        shutdownClose(sockIA);
        return -1;
    }

    data = htonl(reqCoup->estBloque);
    err = send(sockIA, &data, sizeof(int), 0);
    if (err <= 0)
    {
        perror("joueur> erreur send estBloque IA");
        shutdownClose(sockIA);
        return -2;
    }

    data = htonl(pion.typePion);
    err = send(sockIA, &data, sizeof(int), 0);
    if (err <= 0)
    {
        perror("joueur> erreur send typePion IA");
        shutdownClose(sockIA);
        return -3;
    }

    data = htonl(caseCible.l);
    err = send(sockIA, &data, sizeof(int), 0);
    if (err <= 0)
    {
        perror("joueur> erreur send ligne IA");
        shutdownClose(sockIA);
        return -4;
    }

    data = htonl(caseCible.c);
    err = send(sockIA, &data, sizeof(int), 0);
    if (err <= 0)
    {
        perror("joueur> erreur send colonne IA");
        shutdownClose(sockIA);
        return -5;
    }

    data = htonl(reqCoup->propCoup);
    err = send(sockIA, &data, sizeof(int), 0);
    if (err <= 0)
    {
        perror("joueur> erreur send colonne IA");
        shutdownClose(sockIA);
        return -6;
    }

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

int jouerPartie (int sockServeur, int commence, TCoul couleur, int idJoueur)
{
    int err, joueur = commence, continuer = 1, data;
    TCoupReq reqCoup;
    TCoupRep repCoup;
    TCase caseCible;
    TPion pion;

    printf("joueur> id=%d commence ? %d\n", idJoueur, commence);

    while (continuer)
    {
        //Si c'est à nous de jouer.
        if (joueur)
        {
            printf("ReqCoup :\n");
            printf("estBloque (0|1) : ");
            scanf("%d", &data);
            reqCoup.estBloque = data;
            printf("typePion (0:CYLINDRE|1:PAVE|2:SPHERE|3:TETRAEDRE) : ");
            scanf("%d", &data);
            pion.typePion = data;
            pion.coulPion = couleur;
            printf("ligne (0:UN|1:DEUX|2:TROIS|3:QUATRE) : ");
            scanf("%d", &data);
            caseCible.l = data;
            printf("colonne (0:A|1:B|2:C|3:D) : ");
            scanf("%d", &data);
            caseCible.c = data;
            printf("propCoup (0:CONT|1:GAGNE|2:NUL|3:PERDU) : ");
            scanf("%d", &data);
            reqCoup.propCoup = data;

            reqCoup.idRequest = COUP;
            reqCoup.numPartie = 1;//TODO
            reqCoup.pion = pion;
            reqCoup.posPion = caseCible;

            //Envoi du coup.
            err = send(sockServeur, &reqCoup, sizeof(TCoupReq), 0);
            if (err <= 0)
            {
                perror("joueur> erreur send req coup");
                shutdownClose(sockServeur); //TODO select read + write pour gérer la réception du timeout
                return -5;
            }

            //Réception de la validation du coup.
            err = recv(sockServeur, &repCoup, sizeof(TCoupRep), 0);
            if (err <= 0)
            {
                perror("joueur> erreur recv rep coup");
                shutdownClose(sockServeur);
                return -6;
            }

            //Arrêt en cas d'erreur sur le coup joué.
            if (repCoup.err != ERR_OK)
            {
                printf("joueur> erreur sur le coup joué\n");
                shutdownClose(sockServeur);
                return -7;//TODO: improve
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
        //Si c'est à l'adversaire de jouer.
        else
        {
            //Réception de la validation du coup adverse.
            err = recv(sockServeur, &repCoup, sizeof(TCoupRep), 0);
            if (err <= 0)
            {
                perror("joueur> erreur recv rep coup adverse");
                shutdownClose(sockServeur);
                return -8;
            }

            afficherValidationCoup(repCoup, joueur);

            //Fin de partie le cas échéant.
            if (repCoup.propCoup != CONT)
            {
                continuer = 0;
            }
            //Sinon c'est à nous de jouer au prochain coup.
            else
            {
                joueur = 1;

                //Réception du coup adverse.
                err = recv(sockServeur, &reqCoup, sizeof(TCoupReq), 0);
                if (err <= 0)
                {
                    perror("joueur> erreur recv req coup adverse");
                    shutdownClose(sockServeur);
                    return -9;
                }
            }
        }
    }

    return 0;
}

int jouerPartieIA (int sockServeur, int sockIA, int commence, TCoul couleur, int idJoueur)
{
    int err, joueur = commence, continuer = 1, data;
    TCoupReq reqCoup;
    TCoupRep repCoup;

    printf("joueur> id=%d commence ? %d\n", idJoueur, commence);

    //Envoi du signal d'initialisation de partie.
    if (couleur == BLANC)
    {
        data = htonl(CODE_NV_PARTIE_BLANC);
    }
    else
    {
        data = htonl(CODE_NV_PARTIE_NOIR);
    }
    err = send(sockIA, &data, sizeof(int), 0);
    if (err <= 0)
    {
        perror("joueur> erreur send code nv partie");
        shutdownClose(sockIA);
        return -1;
    }
    err = recvIntFromJava(sockIA, &data);
    if (err < 0)
    {
        perror("joueur> erreur recv code ok init");
        shutdownClose(sockIA);
        return -2;
    }
    if (data != CODE_OK)
    {
        printf("joueur> erreur init partie !CODE_OK\n");//TODO close ?
        return -3;
    }

    while (continuer)
    {
        //Si c'est à nous de jouer.
        if (joueur)
        {
            //Calcul du prochain coup.
            err = prochainCoup(sockIA, &reqCoup, couleur);
            if (err < 0)
            {
                printf("joueur> erreur calcul prochain coup fdIA=%d\n", sockIA);
                return -4;
            }

            //Envoi du coup calculé.
            err = send(sockServeur, &reqCoup, sizeof(TCoupReq), 0);
            if (err <= 0)
            {
                perror("joueur> erreur send req coup");
                shutdownClose(sockServeur); //TODO select read + write pour gérer la réception du timeout
                return -5;
            }

            //Réception de la validation du coup.
            err = recv(sockServeur, &repCoup, sizeof(TCoupRep), 0);
            if (err <= 0)
            {
                perror("joueur> erreur recv rep coup");
                shutdownClose(sockServeur);
                return -6;
            }

            //Arrêt en cas d'erreur sur le coup joué.
            if (repCoup.err != ERR_OK)
            {
                printf("joueur> erreur sur le coup joué\n");
                shutdownClose(sockServeur);
                return -7;//TODO: improve
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
        //Si c'est à l'adversaire de jouer.
        else
        {
            //Réception de la validation du coup adverse.
            err = recv(sockServeur, &repCoup, sizeof(TCoupRep), 0);
            if (err <= 0)
            {
                perror("joueur> erreur recv rep coup adverse");
                shutdownClose(sockServeur);
                return -8;
            }

            afficherValidationCoup(repCoup, joueur);

            //Fin de partie le cas échéant.
            if (repCoup.propCoup != CONT)
            {
                continuer = 0;
            }
            //Sinon c'est à nous de jouer au prochain coup.
            else
            {
                joueur = 1;

                //Réception du coup adverse.
                err = recv(sockServeur, &reqCoup, sizeof(TCoupReq), 0);
                if (err <= 0)
                {
                    perror("joueur> erreur recv req coup adverse");
                    shutdownClose(sockServeur);
                    return -9;
                }
                
                //Envoi du coup adverse à l'IA.
                err = adversaireCoup(sockIA, &reqCoup);
                if (err < 0)
                {
                    printf("joueur> erreur envoi coup adverse IA fdIA=%d\n", sockIA);
                    return -10;
                }
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
        err,
        idJoueur = rand() % 100;//TODO projet fini -> enlver affichages
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
        printf("joueur> couleur incorrecte : B (blanc) ou N (noir)\n");
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
    err = recv(sock, &repPartie, sizeof(TPartieRep), 0);
    if (err <= 0) 
    {
        perror("joueur> erreur recv partie");
        shutdownClose(sock);
        return -5;
    }
    printf("joueur> %s VS %s fd=%d\n", reqPartie.nomJoueur, repPartie.nomAdvers, sock);

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
            return -9;
        }

        printf("joueur> début jeu IA\n");

        //Première manche.
        err = jouerPartieIA(sock, sockIA, (reqPartie.coulPion == BLANC ? 1 : 0), reqPartie.coulPion, idJoueur);
        if (err < 0)
        {
            printf("joueur> erreur 1ere partie\n");
            return -10;
        }

        //Deuxième manche.
        err = jouerPartieIA(sock, sockIA, (reqPartie.coulPion == BLANC ? 0 : 1), reqPartie.coulPion, idJoueur);
        if (err < 0)
        {
            printf("joueur> erreur 2eme partie\n");
            return -11;
        }

        shutdownCloseBoth(sock, sockIA);
    }
    else
    {
        //Choix des coups manuel
        printf("joueur> début jeu manuel\n");

        //Première manche.
        err = jouerPartie(sock, (reqPartie.coulPion == BLANC ? 1 : 0), reqPartie.coulPion, idJoueur);
        if (err < 0)
        {
            printf("joueur> erreur 1ere partie\n");
            return -12;
        }

        //Deuxième manche.
        err = jouerPartie(sock, (reqPartie.coulPion == BLANC ? 0 : 1), reqPartie.coulPion, idJoueur);
        if (err < 0)
        {
            printf("joueur> erreur 2eme partie\n");
            return -13;
        }

        shutdownClose(sock);
    }

    return 0;
}