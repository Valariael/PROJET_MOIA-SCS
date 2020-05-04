#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
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

			default:
				testsContinue = 0;
				break;
		}
	}
	shutdownClose(sockConn);

	return 0;
}