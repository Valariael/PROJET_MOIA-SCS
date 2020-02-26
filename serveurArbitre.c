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

int paireJoueurValides(int *sockJoueur1, int *sockJoueur2, int sockConnexion)
{
	int tailleAdr, err;
	struct sockaddr_in adrJoueur1, adrJoueur2;
	TPartieReq reqPartie1, reqPartie2;
	TPartieRep repPartie1, repPartie2;

	*sockJoueur1 = 0;
	*sockJoueur2 = 0;
	while (*sockJoueur1 <= 0)
	{
		*sockJoueur1 = accept(sockConnexion,
			(struct sockaddr *)&adrJoueur1,
			(socklen_t *)&tailleAdr);
		if(*sockJoueur1 < 0) 
		{
			perror("erreur accept joueur 1");
			continue;
		}
		printf("debug> j1 fd=%d\n", *sockJoueur1);

		err = recv(*sockJoueur1, &reqPartie1, sizeof(TPartieReq), 0);
		if (err <= 0)
		{
			perror("erreur recv partie 1");
			shutdown(*sockJoueur1, SHUT_RDWR);
			close(*sockJoueur1);
			*sockJoueur1 = 0;
			continue;
		}
		printf("debug> j1 nom=%s\n", reqPartie1.nomJoueur);
	}

	while (*sockJoueur2 <= 0) 
	{
		*sockJoueur2 = accept(sockConnexion,
			(struct sockaddr *)&adrJoueur2,
			(socklen_t *)&tailleAdr);
		if(*sockJoueur2 < 0) 
		{
			perror("erreur accept joueur 2");
			continue;
		}
		printf("debug> j2 fd=%d\n", *sockJoueur2);

		err = recv(*sockJoueur2, &reqPartie2, sizeof(TPartieReq), 0);
		if (err <= 0)
		{
			perror("erreur recv partie 2");
			shutdown(*sockJoueur2, SHUT_RDWR);
			close(*sockJoueur2);
			*sockJoueur2 = 0;
			continue;
		}
		printf("debug> j2 nom=%s\n", reqPartie2.nomJoueur);
	}

	repPartie1.err = ERR_OK;
	strcpy(repPartie1.nomAdvers, reqPartie2.nomJoueur);
	repPartie2.err = ERR_OK;
	strcpy(repPartie2.nomAdvers, reqPartie1.nomJoueur);
	repPartie1.validCoulPion = OK;
	if(reqPartie1.coulPion == reqPartie2.coulPion)
	{
		repPartie2.validCoulPion = KO;
	}
	else
	{
		repPartie2.validCoulPion = OK;
	}

	err = send(*sockJoueur1, &repPartie1, sizeof(TPartieRep), 0);
	if (err <= 0)
	{
		perror("erreur send partie 1");
		shutdown(*sockJoueur1, SHUT_RDWR);
		close(*sockJoueur1);
		*sockJoueur1 = 0;

		repPartie2.err = ERR_PARTIE;
		err = send(*sockJoueur2, &repPartie2, sizeof(TPartieRep), 0);
		if(err <= 0) 
		{
			perror("erreur send erreur partie 2");
			shutdown(*sockJoueur2, SHUT_RDWR);
			close(*sockJoueur2);
			*sockJoueur2 = 0;
			return -2;
		}
		//TODO close ?

		return -1;
	}

	err = send(*sockJoueur2, &repPartie2, sizeof(TPartieRep), 0);
	if (err <= 0)
	{
		perror("erreur send partie 2");
		shutdown(*sockJoueur2, SHUT_RDWR);
		close(*sockJoueur2);
		*sockJoueur2 = 0;

		repPartie1.err = ERR_PARTIE;
		err = send(*sockJoueur1, &repPartie1, sizeof(TPartieRep), 0);
		if(err <= 0) 
		{
			perror("erreur send erreur partie 1");
			shutdown(*sockJoueur1, SHUT_RDWR);
			close(*sockJoueur1);
			*sockJoueur1 = 0;
			return -4;
		}
		//TODO close ?
		
		return -3;
	}

	return 0;
}

int main(int argc, char **argv)
{
	int sockConnexion,
	sockJoueur1,
	sockJoueur2,
	portServeur,
	err,
	estServeur = 1;
	pid_t pid;

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

	while (estServeur)
	{
		err = paireJoueurValides(&sockJoueur1, &sockJoueur2, sockConnexion);
		if(err < 0)
		{
			perror("erreur paire joueurs");
			continue;
		}
		printf("debug> paire de joueurs connectés fd1=%d fd2=%d\n", sockJoueur1, sockJoueur2);

		pid = fork();
		switch (pid)
		{
			case 0:
			printf("debug> processus fils pid=%d\n", pid);
			close(sockConnexion);
			estServeur = 0;
			break;

			case -1:
			perror("erreur fork jeu");
			shutdown(sockConnexion, SHUT_RDWR);
			close(sockConnexion);
			shutdown(sockJoueur1, SHUT_RDWR);
			close(sockJoueur1);
			shutdown(sockJoueur2, SHUT_RDWR);
			close(sockJoueur2);
			return -3;

			default:
			printf("debug> processus pere pid=%d\n", pid);
			close(sockJoueur1);
			close(sockJoueur2);
			break;
		}
	}

	printf("debug> début jeu\n");
	//jeu

	return 0;
}