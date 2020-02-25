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
	int sockConnexion,
	sockJoueur1,
	sockJoueur2,
	portServeur,
	err,
	tailleAdr;
	pid_t pid;
	struct sockaddr_in adrJoueur1, adrJoueur2;
	TPartieReq reqPartie1, reqPartie2;

	if (argc != 2)
	{
		printf("usage : %s <port>\n", argv[0]);
		return -1;
	}

	portServeur = atoi(argv[1]);
	sockConnexion = socketServeur(portServeur);
	if (sockConnexion < 0) 
	{
        perror("erreur creation socket serveur");
        return -2;
    }

	while (1)
	{
		while (sockJoueur1 <= 0) 
		{
			sockJoueur1 = accept(sockConnexion,
				(struct sockaddr *)&adrJoueur1,
				(socklen_t *)&tailleAdr);
			if(sockJoueur1 < 0) 
			{
				perror("erreur accept joueur 1");
				continue;
			}
			printf("debug> j1 fd=%d\n", sockJoueur1);

			err = recv(sockJoueur1, &reqPartie1, sizeof(TPartieReq), 0);
			if (err <= 0)
			{
				perror("erreur recv partie 1");
				shutdown(sockJoueur1, SHUT_RDWR);
				close(sockJoueur1);
				sockJoueur1 = 0;
				continue;
			}
		}
		while (sockJoueur2 <= 0) 
		{
			sockJoueur2 = accept(sockConnexion,
				(struct sockaddr *)&adrJoueur2,
				(socklen_t *)&tailleAdr);
			if(sockJoueur2 < 0) 
			{
				perror("erreur accept joueur 2");
				continue;
			}
			printf("debug> j2 fd=%d\n", sockJoueur2);

			err = recv(sockJoueur2, &reqPartie2, sizeof(TPartieReq), 0);
			if (err <= 0)
			{
				perror("erreur recv partie 2");
				shutdown(sockJoueur2, SHUT_RDWR);
				close(sockJoueur2);
				sockJoueur2 = 0;
				continue;
			}
		}

		pid = fork();
		switch (pid)
		{
			case 0:
			printf("debug> processus fils pid=%d\n", pid);
    		shutdown(sockConnexion, SHUT_RDWR);
			close(sockConnexion);
    		shutdown(sockJoueur1, SHUT_RDWR);
			close(sockJoueur1);
    		shutdown(sockJoueur2, SHUT_RDWR);
			close(sockJoueur2);
			break;

			case -1:
			perror("erreur fork jeu");
    		shutdown(sockConnexion, SHUT_RDWR);
			close(sockConnexion);
    		shutdown(sockJoueur1, SHUT_RDWR);
			close(sockJoueur1);
    		shutdown(sockJoueur2, SHUT_RDWR);
			close(sockJoueur2);
			break;

			default:
			printf("debug> processus pere pid=%d\n", pid);
    		shutdown(sockConnexion, SHUT_RDWR);
			close(sockConnexion);
    		shutdown(sockJoueur1, SHUT_RDWR);
			close(sockJoueur1);
    		shutdown(sockJoueur2, SHUT_RDWR);
			close(sockJoueur2);
			break;
		}
		break;
	}

	return 0;
}