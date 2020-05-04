#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <string.h>
#include "../src/protocolQuantik.h"
#include "../src/libSockets.h"
#include "../src/libServeurArbitre.h"

int verifIdRequeteTest1(int sock)
{
	int err;
	TCoupReq* coupReq = malloc(sizeof(TCoupReq));
	TCoupRep* coupRep = malloc(sizeof(TCoupRep));

	coupReq->idRequest = COUP;
	err = send(sock, coupReq, sizeof(TCoupReq), 0);
	if (err <= 0)
	{
		perror("serveurTest> erreur send TCoupReq verifIdRequete1");
		return -1;
	}

	err = recv(sock, coupRep, sizeof(TCoupRep), 0);
	if (err <= 0)
	{
		perror("serveurTest> erreur recv TCoupRep verifIdRequete1");
		return -2;
	}

	shutdownClose(sock);
	return 0;
}

int verifIdRequeteTest2(int sock)
{
	int err;
	TPartieReq* partieReq = malloc(sizeof(TPartieReq));
	TPartieRep* partieRep = malloc(sizeof(TPartieRep));

	partieReq->idReq = PARTIE;
	err = send(sock, partieReq, sizeof(TPartieReq), 0);
	if (err <= 0)
	{
		perror("serveurTest> erreur send TPartieReq verifIdRequete2");
		return -1;
	}

	err = recv(sock, partieRep, sizeof(TPartieRep), 0);
	if (err <= 0)
	{
		perror("serveurTest> erreur recv TPartieRep verifIdRequete2");
		return -2;
	}

	shutdownClose(sock);
	return 0;
}

int verifIdRequeteTest3(int sock)
{
	int err;
	TPartieReq* partieReq = malloc(sizeof(TPartieReq));

	partieReq->idReq = PARTIE;
	err = send(sock, partieReq, sizeof(TPartieReq), 0);
	if (err <= 0)
	{
		perror("serveurTest> erreur send TPartieReq verifIdRequete3");
		return -1;
	}

	shutdownClose(sock);
	return 0;
}

int verifIdRequeteTest4(int sock)
{
	int err;
	TPartieReq* partieReq = malloc(sizeof(TPartieReq));

	partieReq->idReq = PARTIE;
	err = send(sock, partieReq, sizeof(TPartieReq), 0);
	if (err <= 0)
	{
		perror("serveurTest> erreur send TPartieReq verifIdRequete4");
		return -1;
	}

	shutdownClose(sock);
	return 0;
}

int connecteJoueurTest(int sock)
{
	int err, sockTarget;
	char s[T_NOM] = "joueur";
	TPartieReq* partieReq = malloc(sizeof(TPartieReq));
	TPartieReq* partieRep = malloc(sizeof(TPartieRep));

	partieReq->idReq = COUP;
	strncpy(partieReq->nomJoueur, s, T_NOM);
	sockTarget = socketClient("127.0.0.1", 8081);

	err = send(sockTarget, partieReq, sizeof(TPartieReq), 0);
	if (err <= 0)
	{
		perror("serveurTest> erreur send TPartieReq connecteJoueur");
		return -1;
	}
	shutdownClose(sockTarget);

	partieReq->idReq = PARTIE;
	partieReq->coulPion = -1;
	sockTarget = socketClient("127.0.0.1", 8081);

	err = send(sockTarget, partieReq, sizeof(TPartieReq), 0);
	if (err <= 0)
	{
		perror("serveurTest> erreur send TPartieReq connecteJoueur");
		return -1;
	}
	err = recv(sockTarget, partieRep, sizeof(TPartieRep), 0);
	if (err <= 0)
	{
		perror("serveurTest> erreur recv TPartieRep connecteJoueur");
		return -2;
	}
	shutdownClose(sockTarget);

	partieReq->coulPion = BLANC;
	sockTarget = socketClient("127.0.0.1", 8081);

	err = send(sockTarget, partieReq, sizeof(TPartieReq), 0);
	if (err <= 0)
	{
		perror("serveurTest> erreur send TPartieReq connecteJoueur");
		return -1;
	}


	err = send(sock, &sockTarget, sizeof(int), 0);
	if (err <= 0)
	{
		perror("serveurTest> erreur send target sock connecteJoueur");
		return -1;
	}
	shutdownClose(sockTarget);
	shutdownClose(sock);
	return 0;
}

int ackJoueursConnectesTest(int sock)
{
	int err, sockTarget;
	TPartieReq* partieRep = malloc(sizeof(TPartieRep));

	sockTarget = socketClient("127.0.0.1", 8081);

	err = recv(sockTarget, partieRep, sizeof(TPartieRep), 0);
	if (err <= 0)
	{
		perror("serveurTest> erreur recv TPartieRep ackJoueursConnectes");
		return -1;
	}

	shutdownClose(sockTarget);

	sockTarget = socketClient("127.0.0.1", 8081);

	err = recv(sockTarget, partieRep, sizeof(TPartieRep), 0);
	if (err <= 0)
	{
		perror("serveurTest> erreur recv TPartieRep ackJoueursConnectes");
		return -2;
	}

	shutdownClose(sockTarget);
	shutdownClose(sock);
	return 0;
}

int main(int argc, char const *argv[])
{
	int testsContinue = 1, nTest, sockTrans, sockConn, tailleAdr, err;
	struct sockaddr_in adr;

	sockConn = socketServeur(8080);
	while (testsContinue)
	{
		sockTrans = accept(sockConn,
			(struct sockaddr *)&adr,
			(socklen_t *)&tailleAdr);
		printf("serveurTest> connexion acceptée\n");

		err = recv(sockTrans, &nTest, sizeof(int), 0);
		if (err <= 0)
		{
			perror("serveurTest> erreur recv nTest");
			return -1;
		}

		printf("serveurTest> code recu : %d\n", nTest);
		switch (nTest)
		{
			case 1:
				verifIdRequeteTest1(sockTrans);
				break;

			case 2:
				verifIdRequeteTest2(sockTrans);
				break;

			case 3:
				verifIdRequeteTest3(sockTrans);
				break;

			case 4:
				verifIdRequeteTest4(sockTrans);
				break;

			case 5:
				connecteJoueurTest(sockTrans);
				break;

			case 6:
				ackJoueursConnectesTest(sockTrans);
				break;

			default:
				testsContinue = 0;
				break;
		}
	}
	shutdownClose(sockConn);

	return 0;
}