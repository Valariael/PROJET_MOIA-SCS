#include <stdio.h>
#include <stdlib.h>
#include <netinet/ip.h>
#include <unistd.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/select.h>
#include <sys/time.h>
#include <sys/signal.h>
#include <string.h>
#include "libSockets.h"
#include "protocolQuantik.h"
#include "libServeurArbitre.h"

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
	struct sigaction sa;

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

	//Pour traiter le signal SIGCHLD et éviter les zombies.
	sa.sa_handler = sigchildHandler; 
	sigemptyset(&sa.sa_mask);
	sa.sa_flags = 0;
	sigaction(SIGCHLD, &sa, NULL);
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
		shutdownCloseBoth(sockJoueur1,sockJoueur2);
		return -3;
	}

	//Deuxième manche
	err = jouerPartie(sockJoueur2, sockJoueur1);
	if (err < 0)
	{
		printf("arbitre> erreur 2eme partie fdB=%d fdN=%d\n", sockJoueur2, sockJoueur1);
		shutdownCloseBoth(sockJoueur1,sockJoueur2);
		return -4;
	}
}