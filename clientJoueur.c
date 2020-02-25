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

    if (argc != 5) 
    {
        printf("usage : %s <nomMachineDest> <portDest> <nomJoueur> <couleurPion>\n", argv[0]);
        return -1;
    }

    nomMachineDest = argv[1];
    portDest = atoi(argv[2]);
    reqPartie.idReq = PARTIE;
    strcpy(reqPartie.nomJoueur, argv[3]);
    if(strcmp(argv[4], "B") == 0) 
    {
        reqPartie.coulPion = BLANC;
    } 
    else if(strcmp(argv[4], "N") == 0) 
    {
        reqPartie.coulPion = NOIR;
    } 
    else 
    {
        printf("usage : %s <nomMachineDest> <portDest> <nomJoueur> <couleurPion>\n", argv[0]);
        printf("couleur incorrecte : B (blanc) ou N (noir)\n");
        return -2;
    }

    sock = socketClient(nomMachineDest, portDest);
    if (sock < 0) 
    {
        perror("erreur creation socket client");
        return -3;
    }

    err = send(sock, &reqPartie, sizeof(TPartieReq), 0);
    if (err <= 0)
    {
        perror("erreur send partie");
        shutdown(sock, SHUT_RDWR);
        close(sock);
        return -2;
    }

    shutdown(sock, SHUT_RDWR);
    close(sock);

    return 0;
}