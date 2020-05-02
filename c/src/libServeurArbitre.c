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
#include "libServeurArbitre.h"

int verifIdRequete (int *sockJoueur, int idAttendu)
{
	int err, dataId;
	TPartieReq partieReq;
	TCoupReq coupReq;
	TPartieRep partieRep;
	TCoupRep coupRep;

	err = recv(*sockJoueur, &dataId, sizeof(TIdReq), MSG_PEEK);
	if (err <= 0)
	{
		perror("arbitre> erreur peek idReq");
		return -1;
	}

	if (dataId != idAttendu)
	{
		printf("arbitre> erreur idReq incorrect");

		if (dataId == PARTIE)
		{
			err = recv(*sockJoueur, &partieReq, sizeof(TPartieReq), 0);
		}
		else
		{
			err = recv(*sockJoueur, &coupReq, sizeof(TCoupReq), 0);
		}
		if (err <= 0)
		{
			perror("arbitre> erreur recv vidage tampon");
			return -2;
		}

		if (dataId == PARTIE)
		{
			partieRep.err = ERR_TYP;
			err = send(*sockJoueur, &partieRep, sizeof(TPartieRep), 0);
		}
		else
		{
			coupRep.err = ERR_TYP;
			err = send(*sockJoueur, &coupRep, sizeof(TCoupRep), 0);
		}
		if (err <= 0)
		{
			perror("arbitre> erreur send ERR_TYP");
			return -3;
		}
		
		return -4;
	}

	return 0;
}

void connecteJoueur (int *sockJoueur, int sockConnexion, TPartieReq *reqPartie)
{
	int tailleAdr, err;
	struct sockaddr_in adrJoueur;
	TPartieRep partieRep;

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

		err = verifIdRequete(sockJoueur, PARTIE);
		if (err == 0) err = recv(*sockJoueur, reqPartie, sizeof(TPartieReq), 0);
		if (err <= 0)
		{
			perror("arbitre> erreur recv partie");
			shutdownClose(*sockJoueur);
			*sockJoueur = 0;
			continue;
		}

		if (reqPartie->coulPion != BLANC && reqPartie->coulPion != NOIR)//TODO : more error handling ?
		{
			partieRep.err = ERR_PARTIE;
			err = send(*sockJoueur, &partieRep, sizeof(TPartieRep), 0);
			if (err <= 0)
			{
				perror("arbitre> erreur send ERR_PARTIE");
			}
			printf("arbitre> erreur coulPion req partie\n");
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

		//En cas d'erreur, envoi d'une réponse ERR_PARTIE à l'autre joueur
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

	return 0;
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
		return -1;
	}

	//Envoi réponse coup deuxième joueur.
	err = send(sockAutreJoueur, repCoup, sizeof(TCoupRep), 0);
	if (err <= 0)
	{
		perror("arbitre> erreur send rep coup 2");
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
		err = verifIdRequete(&sockJoueur, COUP);
		if (err == 0) err = recv(sockJoueur, &reqCoup, sizeof(TCoupReq), 0);//TODO verif intervalle valeurs > ERR_COUP
		if (err <= 0)
		{
			perror("arbitre> erreur recv coup 1");

			repCoup.err = ERR_COUP;
			err = send(sockAutreJoueur, &repCoup, sizeof(TCoupRep), 0);
			if (err <= 0)
			{
				perror("arbitre> erreur send ERR_COUP adversaire");
			}

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
//TODO vérifier que la couleur ne swap pas à la seconde partie
int jouerPartie (int sockJoueur1, int sockJoueur2)
{
	int err, nsfd, sockJoueurCourant = sockJoueur1, continuerPartie = 1;
	struct timeval timeout;
	fd_set readSet;
	TCoupRep repCoup;
	
	initialiserPartie();
	while (continuerPartie)
	{//TODO refactor shutdown
		//Préparation du select pour le timeout.
		FD_ZERO(&readSet);
		FD_SET(sockJoueur1, &readSet);
		FD_SET(sockJoueur2, &readSet);
		timeout.tv_usec = 5000000;
		nsfd = (sockJoueur1 > sockJoueur2 ? sockJoueur1 + 1 : sockJoueur2 + 1);
		err = select(nsfd, &readSet, NULL, NULL, &timeout);
		if (err < 0) 
		{
			//Erreur au select.
			perror("arbitre> erreur select");
			return -1;
		} 
		else if (err == 0)
		{
			//Temps de jeu écoulé, envoi de la réponse TIMEOUT.
			printf("arbitre> fd=%d temps écoulé\n", sockJoueurCourant);

			repCoup.err = ERR_OK;
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