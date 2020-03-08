#include <stdio.h>
#include <stdlib.h>
#include <netinet/ip.h>
#include <unistd.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/select.h>
#include <string.h>
#include "libSockets.h"
#include "protocolQuantik.h"
#include "validation.h"

void connecteJoueur(int *sockJoueur, int sockConnexion, TPartieReq *reqPartie)
{
	int tailleAdr, err;
	struct sockaddr_in adrJoueur;

	//Tant que la connexion d'un joueur n'a pas réussi on réessaie.
	while (*sockJoueur <= 0)
	{
		*sockJoueur = accept(sockConnexion,
			(struct sockaddr *)&adrJoueur,
			(socklen_t *)&tailleAdr);
		if (*sockJoueur < 0) 
		{
			perror("arbitre> erreur connexion joueur");
			continue;
		}
		printf("arbitre> joueur connecté fd=%d\n", *sockJoueur);

		err = recv(*sockJoueur, reqPartie, sizeof(TPartieReq), 0);
		if (err <= 0)
		{//TODO: check idReq is PARTIE not COUP > ERR_TYP
			perror("arbitre> erreur recv partie");
			shutdown(*sockJoueur, SHUT_RDWR);
			close(*sockJoueur);
			*sockJoueur = 0;
			continue;
		}
		printf("arbitre> nom joueur=%s\n", reqPartie->nomJoueur);
	}
}

int ackJoueursConnectes(int *sockJoueur, int *sockAutreJoueur, TPartieRep *repPartie, TPartieRep *repPartieAutre)
{
	int err;

	//Envoi de la réponse à la requête de partie.
	err = send(*sockJoueur, repPartie, sizeof(TPartieRep), 0);
	if (err <= 0)
	{
		perror("arbitre> erreur send partie");
		shutdown(*sockJoueur, SHUT_RDWR);
		close(*sockJoueur);
		*sockJoueur = 0;

		repPartieAutre->err = ERR_PARTIE;
		err = send(*sockAutreJoueur, repPartieAutre, sizeof(TPartieRep), 0);
		if (err <= 0) 
		{
			perror("arbitre> erreur send erreur partie");
			shutdown(*sockAutreJoueur, SHUT_RDWR);
			close(*sockAutreJoueur);
			*sockAutreJoueur = 0;
			return -2;
		}
		//TODO close ?

		return -1;
	}
}

int paireJoueurValides (int *sockJoueur1, int *sockJoueur2, int sockConnexion)
{
	int err;
	TPartieReq reqPartie1, reqPartie2;
	TPartieRep repPartie1, repPartie2;

	*sockJoueur1 = 0;
	*sockJoueur2 = 0;

	//Connexion premier joueur.
	connecteJoueur(sockJoueur1, sockConnexion, &reqPartie1);

	//Connexion deuxième joueur.
	connecteJoueur(sockJoueur2, sockConnexion, &reqPartie2);

	//Préparation des réponses.
	repPartie1.err = ERR_OK;
	strcpy(repPartie1.nomAdvers, reqPartie2.nomJoueur);
	repPartie2.err = ERR_OK;
	strcpy(repPartie2.nomAdvers, reqPartie1.nomJoueur);
	repPartie1.validCoulPion = OK;
	if (reqPartie1.coulPion == reqPartie2.coulPion)
	{
		repPartie2.validCoulPion = KO;
	}
	else
	{
		repPartie2.validCoulPion = OK;
	}

	//Envoi réponse au premier joueur.
	err = ackJoueursConnectes(sockJoueur1, sockJoueur2, &repPartie1, &repPartie2);

	//Envoi réponse au deuxième joueur.
	err = ackJoueursConnectes(sockJoueur2, sockJoueur1, &repPartie2, &repPartie1);

	return 0;
}

int traiterCoup(int sockJoueur, int sockAutreJoueur, int sockJoueurCourant, int numJoueur)
{
	if (sockJoueurCourant == sockJoueur)
	{
		err = recv(sockJoueur, &reqCoup, sizeof(TCoupReq), 0);
		if (err <= 0)
		{
			perror("arbitre> erreur recv coup 1");
			shutdown(sockJoueur, SHUT_RDWR);
			shutdown(sockAutreJoueur, SHUT_RDWR);
			close(sockJoueur);
			close(sockAutreJoueur);
		}
		else
		{
			coupValide = validationCoup(numJoueur, reqCoup, &resultatValidation);
			if (!coupValide || (reqCoup.propCoup != resultatValidation))
			{
				//TODO : triche
			}
			else
			{

			}
		}
	}
	else 
	{
		//TODO: pas son tour
	}

	return 0;
}

int jouerPartie(int sockJoueur1, int sockJoueur2)
{
	TCoupReq reqCoup;
	TCoupRep repCoup;
	int err, nsfd, sockJoueurCourant = sockJoueur1, continuerPartie;
	struct timeval timeout;
	fd_set readSet;
	TPropCoup resultatValidation;
	bool coupValide;
	
	initialiserPartie();
	while (continuerPartie)  //TODO: not infinite
	{

		FD_ZERO(&readSet);
		FD_SET(sockJoueur1, &readSet);
		FD_SET(sockJoueur2, &readSet);
		timeout.tv_sec = 5;
		nsfd = (sockJoueur1 > sockJoueur2 ? sockJoueur1 + 1 : sockJoueur2 + 1);

		err = select(nsfd, &readSet, NULL, , NULL, &timeout);
		if (err < 0) 
		{
			perror("arbitre> erreur select");
			//TODO: interruption partie ???
			shutdown(sockJoueur1, SHUT_RDWR);
			shutdown(sockJoueur2, SHUT_RDWR);
			close(sockJoueur1);
			close(sockJoueur2);
			return -1;
		} 
		else if (err == 0)
		{
			printf("arbitre> fd=%d temps écoulé\n", sockJoueurCourant);
			//TODO: timeout
		}
		else
		{
			if (FD_ISSET(sockJoueur1, &readSet) != 0)
			{
				err = traiterCoup(sockJoueur1, sockJoueur2, sockJoueurCourant, 2);
				if (err < 0)
				{
					perror("arbitre> erreur traitement coup 1");
					//TODO: interruption partie ???
					shutdown(sockJoueur1, SHUT_RDWR);
					shutdown(sockJoueur2, SHUT_RDWR);
					close(sockJoueur1);
					close(sockJoueur2);
					return -2;
				}
				else if (err > 0)
				{
					continuerPartie = 0;
					continue; //TODO: a changer
				}
			}
			if (FD_ISSET(sockJoueur2, &readSet) != 0)
			{
				err = traiterCoup(sockJoueur2, sockJoueur1, sockJoueurCourant, 2);
				if (err < 0)
				{
					perror("arbitre> erreur traitement coup 2");
					//TODO: interruption partie ???
					shutdown(sockJoueur1, SHUT_RDWR);
					shutdown(sockJoueur2, SHUT_RDWR);
					close(sockJoueur1);
					close(sockJoueur2);
					return -3;
				}
				else if (err > 0)
				{
					continuerPartie = 0;
					continue; //TODO: a changer
				}
			}
		}
	}
}

int main(int argc, char **argv)
{
	int sockConnexion,
	sockJoueur1,
	sockJoueur2,
	portServeur,
	err,
	estServeur = 1,
	idPartie = 0;
	pid_t pid;

	//Vérification des arguments.
	if (argc != 2)
	{
		printf("arbitre> usage : %s <port>\n", argv[0]);
		return -1;
	}

	//Création du socket de connexion.
	portServeur = atoi(argv[1]);
	sockConnexion = socketServeur(portServeur);
	if (sockConnexion < 0) 
	{
		perror("arbitre> erreur creation socket serveur");
		return -2;
	}

	//Processus d'origine doit continuer à pouvoir lancer des nouvelles parties.
	while (estServeur)
	{
		//Connexion de deux joueurs pour une partie.
		err = paireJoueurValides(&sockJoueur1, &sockJoueur2, sockConnexion);
		if (err < 0)
		{
			perror("arbitre> erreur paire joueurs");
			continue;
		}
		printf("arbitre> paire de joueurs connectés fd1=%d fd2=%d\n", sockJoueur1, sockJoueur2);

		//La partie est exécutée dans le processus fils.
		idPartie++;
		pid = fork();
		switch (pid)
		{
			case 0:
			printf("arbitre> processus fils pid=%d\n", pid);
			close(sockConnexion);
			estServeur = 0;
			break;

			case -1:
			perror("arbitre> erreur fork jeu");
			close(sockConnexion);
			shutdown(sockJoueur1, SHUT_RDWR);
			close(sockJoueur1);
			shutdown(sockJoueur2, SHUT_RDWR);
			close(sockJoueur2);
			return -3;

			default:
			printf("arbitre> processus pere pid=%d\n", pid);
			close(sockJoueur1);
			close(sockJoueur2);
			break;
		}
	}

	printf("arbitre> début jeu\n");
	//Première manche
	// jouerPartie(joueurBlancSock, jnoir etc)
	return 0;
}