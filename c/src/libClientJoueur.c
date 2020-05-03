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
#include "validation.h"
#include "libClientJoueur.h"

int verifCodeRep (int sock)
{
    int err, codeRep;

    err = recv(sock, &codeRep, sizeof(TCodeRep), MSG_PEEK);
    if (err <= 0)
    {
        perror("joueur> erreur peek verif CodeRep");
        return -1;
    }

    if (codeRep != ERR_OK)
    {
        switch (codeRep)
        {
            case ERR_TYP :
            printf("joueur> erreur sur le type de requête\n");
            return -2;

            case ERR_PARTIE : 
            printf("joueur> erreur à la création partie, réessayer\n");
            return -3;

            case ERR_COUP : 
            printf("joueur> erreur sur le coup joué\n");
            return -4;

            default:
            printf("joueur> code erreur inconnu reçu\n");
            return -5;
        }
    }

    return 0;
}

int recvIntFromJava (int sock, int *data)
{
    int err = 0;

    while(err < 4) 
    {
        err = recv(sock, data, sizeof(int), MSG_PEEK);
        if (err < 0)
        {
            perror("joueur> erreur recv Java MSG_PEEK");
            return -1;
        }
    }
    err = recv(sock, data, sizeof(int), 0);
    if (err <= 0)
    {
        perror("joueur> erreur recv Java");
        return -2;
    }
    *data = ntohl(*data);

    return 0;
}

int prochainCoup (int sockIA, TCoupReq *reqCoup, TCoul couleur, int num)
{
    int err, data;
    TCase caseCible;
    TPion pion;

    //Réception du prochain coup à jouer.
    err = recvIntFromJava(sockIA, &data);
    if (err < 0)
    {
        printf("joueur> erreur recv estBloque IA\n");
        return -1;
    }
    reqCoup->estBloque = data;

    err = recvIntFromJava(sockIA, &data);
    if (err < 0)
    {
        printf("joueur> erreur recv typePion IA\n");
        return -2;
    }
    pion.typePion = data;
    pion.coulPion = couleur;

    err = recvIntFromJava(sockIA, &data);
    if (err < 0)
    {
        printf("joueur> erreur recv ligne IA\n");
        return -3;
    }
    caseCible.l = data;

    err = recvIntFromJava(sockIA, &data);
    if (err < 0)
    {
        printf("joueur> erreur recv colonne IA\n");
        return -4;
    }
    caseCible.c = data;

    err = recvIntFromJava(sockIA, &data);
    if (err < 0)
    {
        printf("joueur> erreur recv prop coup IA\n");
        return -5;
    }
    reqCoup->propCoup = data;
    reqCoup->numPartie = num;
    reqCoup->idRequest = COUP;
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
        return -1;
    }

    data = htonl(reqCoup->estBloque);
    err = send(sockIA, &data, sizeof(int), 0);
    if (err <= 0)
    {
        perror("joueur> erreur send estBloque IA");
        return -2;
    }

    data = htonl(pion.typePion);
    err = send(sockIA, &data, sizeof(int), 0);
    if (err <= 0)
    {
        perror("joueur> erreur send typePion IA");
        return -3;
    }

    data = htonl(caseCible.l);
    err = send(sockIA, &data, sizeof(int), 0);
    if (err <= 0)
    {
        perror("joueur> erreur send ligne IA");
        return -4;
    }

    data = htonl(caseCible.c);
    err = send(sockIA, &data, sizeof(int), 0);
    if (err <= 0)
    {
        perror("joueur> erreur send colonne IA");
        return -5;
    }

    data = htonl(reqCoup->propCoup);
    err = send(sockIA, &data, sizeof(int), 0);
    if (err <= 0)
    {
        perror("joueur> erreur send propCoup IA");
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
        printf("joueur> TValCoup inconnu ");
        printf("%d : ",repCoup.validCoup);
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
        printf("%d",repCoup.propCoup);
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

int jouerPartie (int sockServeur, int commence, TCoul couleur, int idJoueur, int num)
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
            reqCoup.numPartie = num;
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
            reqCoup.pion = pion;
            reqCoup.posPion = caseCible;

            //Envoi du coup.
            err = send(sockServeur, &reqCoup, sizeof(TCoupReq), 0);
            if (err <= 0)
            {
                perror("joueur> erreur send req coup");
//TODO select read + write pour gérer la réception du timeout
                return -1;
            }

            //Réception de la validation du coup.
            err = verifCodeRep(sockServeur);
            if (err == 0) err = recv(sockServeur, &repCoup, sizeof(TCoupRep), 0);
            if (err <= 0)
            {
                perror("joueur> erreur recv rep coup");
                return -2;
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
            err = verifCodeRep(sockServeur);
            if (err == 0) err = recv(sockServeur, &repCoup, sizeof(TCoupRep), 0);
            else printf("joueur> erreur sur une requête de l'adversaire\n");
            if (err <= 0)
            {
                perror("joueur> erreur recv rep coup adverse");
                return -4;
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
                    return -5;
                }
            }
        }
    }

    return 0;
}

int jouerPartieIA (int sockServeur, int sockIA, int commence, TCoul couleur, int idJoueur, int num)
{
    int err, joueur = commence, continuer = 1, data, nsfd;
    TCoupReq reqCoup;
    TCoupRep repCoup;
	fd_set readSet;
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
        return -1;
    }
    err = recvIntFromJava(sockIA, &data);
    if (err < 0)
    {
        perror("joueur> erreur recv code ok init");
        return -2;
    }
    if (data != CODE_OK)
    {
        printf("joueur> erreur init partie !CODE_OK\n");
        return -3;
    }

    while (continuer)
    {
        //Si c'est à nous de jouer.
        if (joueur)
        {
            //Envoi du signal pour récupérer le prochain coup.
            data = htonl(CODE_COUP_SELF);
            err = send(sockIA, &data, sizeof(int), 0);
            if (err <= 0)
            {
                perror("joueur> erreur send code req coup self IA");
                return -4;
            }
            
            data = -1;
            FD_ZERO(&readSet);
            FD_SET(sockIA, &readSet);
            FD_SET(sockServeur, &readSet);
            nsfd = (sockIA > sockServeur  ? sockIA + 1 : sockServeur + 1);
            //On réceptionne un premier code_OK pour le coup de secours
            
            err = select(nsfd, &readSet, NULL, NULL, NULL);
            if (err <= 0) 
            {
                //Erreur au select.
                perror("joueur> erreur select");
                return -7;
            }     
            else
            {
                if (FD_ISSET(sockServeur, &readSet) != 0)
                {
                    //Gestion de la réception du TIMEOUT du serveur.
                    err = verifCodeRep(sockServeur);
                    if (err == 0) err = recv(sockServeur, &repCoup, sizeof(TCoupRep), 0);
                    if (err <= 0)
                    {
                        perror("joueur> erreur recv : timeout");
                        return -8;
                    } 
                }
                if (FD_ISSET(sockIA, &readSet) != 0)
                {
                    //Réception de CODE_OK quand le coup est prêt.
                    err = recvIntFromJava(sockIA, &data);
                    if (err < 0)
                    {
                        perror("joueur> erreur recv CODE_OK coup pret");
                        return -9;
                    }
                }
            } 

            //Si le coup est prêt dans les temps, le transmettre au serveur et recevoir la réponse.
            if (data == CODE_OK)
            {
                //Calcul du prochain coup.
                err = prochainCoup(sockIA, &reqCoup, couleur, num);
                if (err < 0)
                {
                    printf("joueur> erreur calcul prochain coup fdIA=%d\n", sockIA);
                    return -10;
                }

                //Envoi du coup calculé.
                err = send(sockServeur, &reqCoup, sizeof(TCoupReq), 0); 
                if (err <= 0)
                {
                    perror("joueur> erreur send ");
                    return -11;
                }
                 //Réception de la validation du coup.
                err = verifCodeRep(sockServeur);
                if (err == 0) err = recv(sockServeur, &repCoup, sizeof(TCoupRep), 0);
                if (err <= 0)
                {
                    perror("joueur> erreur recv rep coup");
                    return -12;
                }

                //Arrêt en cas d'erreur sur le coup joué.
                if (repCoup.err != ERR_OK)
                {
                    printf("joueur> erreur sur le coup joué\n");
                    return -13;//TODO: improve
                }
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
            err = verifCodeRep(sockServeur);
            if (err == 0) err = recv(sockServeur, &repCoup, sizeof(TCoupRep), 0);
            if (err <= 0)
            {
                perror("joueur> erreur recv rep coup adverse");
                return -14;
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
                    return -15;
                }
                
                //Envoi du coup adverse à l'IA.
                err = adversaireCoup(sockIA, &reqCoup);
                if (err < 0)
                {
                    printf("joueur> erreur envoi coup adverse IA fdIA=%d\n", sockIA);
                    return -16;
                }
            }
        }
    }

    return 0;
}