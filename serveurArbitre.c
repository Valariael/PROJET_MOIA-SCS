#include <stdio.h>
#include <stdlib.h>
#include <netinet/ip.h>
#include <unistd.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/select.h>
#include <sys/time.h>
#include <string.h>
#include "libSockets.h"
#include "protocolQuantik.h"
#include "validation.h"

void connecteJoueur (int *sockJoueur, int sockConnexion, TPartieReq *reqPartie)
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
			shutdownClose(*sockJoueur);
			*sockJoueur = 0;
			continue;
		}
		printf("arbitre> nom joueur=%s\n", reqPartie->nomJoueur);
	}
}

int ackJoueursConnectes (int *sockJoueur, int *sockAutreJoueur, TPartieRep *repPartie, TPartieRep *repPartieAutre)
{
	int err;

	//Envoi de la réponse à la requête de partie.
	err = send(*sockJoueur, repPartie, sizeof(TPartieRep), 0);
	if (err <= 0)
	{
		perror("arbitre> erreur send partie");
		shutdownClose(*sockJoueur);
		*sockJoueur = 0;

		//En cas d'erreur, envoi d'une réponse ERR_PARTIE ? TODO verif enoncé
		if (*sockAutreJoueur != 0)
		{
			repPartieAutre->err = ERR_PARTIE;
			err = send(*sockAutreJoueur, repPartieAutre, sizeof(TPartieRep), 0);
			shutdownClose(*sockAutreJoueur);
			*sockAutreJoueur = 0;
			if (err <= 0) 
			{
				perror("arbitre> erreur send erreur partie");
				return -2;
			}
		}

		return -1;
	}
}

int paireJoueurValides (int *sockJoueur1, int *sockJoueur2, int sockConnexion)
{
	int err, tmp;
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
	if (err < 0) 
	{
		printf("arbitre> erreur send réponse partie 1 fd=%d\n", *sockJoueur1);
		return -1;
	}

	//Envoi réponse au deuxième joueur.
	err = ackJoueursConnectes(sockJoueur2, sockJoueur1, &repPartie2, &repPartie1);
	if (err < 0) 
	{
		printf("arbitre> erreur send réponse partie 2 fd=%d\n", *sockJoueur2);
		return -2;
	}

	//On échange les sockets si besoin pour accorder les couleurs choisies avec l'ordre de jeu.
	if (reqPartie1.coulPion == NOIR)
	{
		tmp = *sockJoueur1;
		*sockJoueur1 = *sockJoueur2;
		*sockJoueur2 = tmp;
	}

	return 0;
}

int envoyerRepCoup (int sockJoueur, int sockAutreJoueur, TCoupRep *repCoup)
{
	int err;

	//Envoi réponse coup premier joueur.
	err = send(sockJoueur, repCoup, sizeof(TCoupRep), 0);
	if (err <= 0)
	{
		perror("arbitre> erreur send rep coup 1");
		shutdownCloseBoth(sockJoueur, sockAutreJoueur);
		return -1;
	}

	//Envoi réponse coup deuxième joueur.
	err = send(sockAutreJoueur, repCoup, sizeof(TCoupRep), 0);
	if (err <= 0)
	{
		perror("arbitre> erreur send rep coup 2");
		shutdownCloseBoth(sockJoueur, sockAutreJoueur);
		return -2;
	}

	return 0;
}

int traiterCoup (int sockJoueur, int sockAutreJoueur, int sockJoueurCourant, int numJoueur)
{
	int err;
	TCoupReq reqCoup;
	TCoupRep repCoup;
	bool coupValide;
	TPropCoup resultatValidation = CONT;

	//Vérification que ce soit bien le tour de ce joueur.
	if (sockJoueurCourant == sockJoueur)
	{
		//Réception du coup joué.
		printf("arbitre> recv req coup fd=%d\n", sockJoueur);
		err = recv(sockJoueur, &reqCoup, sizeof(TCoupReq), 0);//TODO check num partie
		if (err <= 0)
		{
			perror("arbitre> erreur recv coup 1");
			shutdownCloseBoth(sockJoueur, sockAutreJoueur);
			return -1;
		}
		else
		{
			//Vérification du coup par l'arbitre.
			coupValide = validationCoup(numJoueur, reqCoup, &resultatValidation);
			if (!coupValide || (reqCoup.propCoup != resultatValidation))
			{
				//En cas de de coup erroné, envoi de la réponse TRICHE.
				repCoup.err = ERR_COUP;
				repCoup.validCoup = TRICHE;
				repCoup.propCoup = PERDU;

				printf("arbitre> send rep triche fd=%d\n", sockJoueur);
				err = envoyerRepCoup(sockJoueur, sockAutreJoueur, &repCoup);
				if (err < 0)
				{
					printf("arbitre> erreur send coup triche par fd1=%d fd2=%d\n", sockJoueur, sockAutreJoueur);
					return -2;
				}
			}
			else
			{
				//En cas de coup valide, envoi de la réponse avec le résultat de la validation.
				repCoup.err = ERR_OK;
				repCoup.validCoup = VALID;
				repCoup.propCoup = resultatValidation;

				printf("arbitre> send rep coup fd=%d\n", sockJoueur);
				err = envoyerRepCoup(sockJoueur, sockAutreJoueur, &repCoup);
				if (err < 0)
				{
					printf("arbitre> erreur send coup valid par fd1=%d fd2=%d\n", sockJoueur, sockAutreJoueur);
					return -3;
				}

				if (resultatValidation != CONT)
				{
					return 1;
				}
				
				printf("arbitre> send coup fd=%d\n", sockAutreJoueur);
				//Si la partie continue, on envoie le coup joué à l'adversaire.
				err = send(sockAutreJoueur, &reqCoup, sizeof(TCoupReq), 0);
				if (err <= 0)
				{
					perror("arbitre> erreur send coup continuer 2");
					shutdownCloseBoth(sockJoueur, sockAutreJoueur);
					return -4;
				}
			}
		}
	}
	else 
	{
		//Sinon ce n'est pas à son tour de jouer.
		repCoup.err = ERR_COUP;
		repCoup.validCoup = TRICHE;
		repCoup.propCoup = PERDU;

		printf("arbitre> send rep triche fd=%d\n", sockJoueur);
		err = envoyerRepCoup(sockJoueur, sockAutreJoueur, &repCoup);
		if (err < 0)
		{
			printf("arbitre> erreur send coup triche par fd1=%d fd2=%d\n", sockJoueur, sockAutreJoueur);
			return -2;
		}

		return 2;
	}

	return 0;
}

int jouerPartie (int sockJoueur1, int sockJoueur2)
{
	int err, nsfd, sockJoueurCourant = sockJoueur1, continuerPartie = 1;
	struct timeval timeout;
	fd_set readSet;
	TCoupRep repCoup;
	
	initialiserPartie();
	while (continuerPartie)
	{
		//Préparation du select pour le timeout.
		FD_ZERO(&readSet);
		FD_SET(sockJoueur1, &readSet);
		FD_SET(sockJoueur2, &readSet);
		timeout.tv_sec = 100;//TODO change
		nsfd = (sockJoueur1 > sockJoueur2 ? sockJoueur1 + 1 : sockJoueur2 + 1);

		err = select(nsfd, &readSet, NULL, NULL, &timeout);
		if (err < 0) 
		{
			//Erreur au select.
			perror("arbitre> erreur select");
			//TODO: interruption partie ???
			shutdownCloseBoth(sockJoueur1, sockJoueur2);
			return -1;
		} 
		else if (err == 0)
		{
			//Temps de jeu écoulé, envoi de la réponse TIMEOUT.
			printf("arbitre> fd=%d temps écoulé\n", sockJoueurCourant);

			repCoup.err = ERR_COUP;
			repCoup.validCoup = TIMEOUT;
			repCoup.propCoup = PERDU;

			err = envoyerRepCoup(sockJoueur1, sockJoueur2, &repCoup);
			if (err < 0)
			{
				printf("arbitre> erreur send coup timeout par fd1=%d fd2=%d\n", sockJoueur1, sockJoueur2);
				return -2;
			}

			continuerPartie = 0;
		}
		else
		{
			if (FD_ISSET(sockJoueur1, &readSet) != 0)
			{
				//Traitement d'une requête COUP du premier joueur.
				err = traiterCoup(sockJoueur1, sockJoueur2, sockJoueurCourant, 1);
				if (err < 0)
				{
					perror("arbitre> erreur traitement coup 1");
					//TODO: interruption partie ???
					shutdownCloseBoth(sockJoueur1, sockJoueur2);
					return -3;
				}
				else if (err > 0)
				{
					continuerPartie = 0;
				}
				else
				{
					sockJoueurCourant = sockJoueur2;
				}
			}
			if (FD_ISSET(sockJoueur2, &readSet) != 0)
			{
				//Traitement d'une requête COUP du deuxième joueur.
				err = traiterCoup(sockJoueur2, sockJoueur1, sockJoueurCourant, 2);
				if (err < 0)
				{
					perror("arbitre> erreur traitement coup 2");
					//TODO: interruption partie ???
					shutdownCloseBoth(sockJoueur1, sockJoueur2);
					return -4;
				}
				else if (err > 0)
				{
					continuerPartie = 0;
				}
				else
				{
					sockJoueurCourant = sockJoueur1;
				}
			}
		}
	}

	return 0;
}

int main (int argc, char **argv)
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
			shutdownCloseBoth(sockJoueur1, sockJoueur2);
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
	err = jouerPartie(sockJoueur1, sockJoueur2);
	if (err < 0)
	{
		printf("arbitre> erreur 1ere partie fdB=%d fdN=%d\n", sockJoueur1, sockJoueur2);
		return -3;
	}

	//Deuxième manche
	err = jouerPartie(sockJoueur2, sockJoueur1);
	if (err < 0)
	{
		printf("arbitre> erreur 2eme partie fdB=%d fdN=%d\n", sockJoueur2, sockJoueur1);
		return -4;
	}

	return 0;
}