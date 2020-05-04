#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include "../src/protocolQuantik.h"
#include "../src/libSockets.h"
#include "../src/libClientJoueur.h"

int verifCodeRepTest(int sock)
{
	int err;
	TCoupRep* coupRep = malloc(sizeof(TCoupRep));

	for (int testCode = -1; testCode < 5; ++testCode)
	{
		coupRep->err = testCode;
		err = send(sock, coupRep, sizeof(TCoupRep), 0);
		if (err <= 0)
		{
			perror("clientTest> erreur send verifCodeRepTest");
			return -1;
		}
	}

	shutdownClose(sock);
	return 0;
}

int recvIntFromJavaTest(int sock)
{
	int err = htonl(10);

	err = send(sock, &err, sizeof(int), 0);
	if (err <= 0)
	{
		perror("clientTest> erreur send recvIntFromJavaTest");
		return -1;
	}

	shutdownClose(sock);
	return 0;	
}

int prochainCoupTest1(int sock)
{
	int data, err;

	data = htonl(1);
	err = send(sock, &data, sizeof(int), 0);
	if (err <= 0)
	{
		perror("clientTest> erreur send estBloque prochainCoup");
		return -1;
	}
	err = send(sock, &data, sizeof(int), 0);
	if (err <= 0)
	{
		perror("clientTest> erreur send typePion prochainCoup");
		return -2;
	}
	err = send(sock, &data, sizeof(int), 0);
	if (err <= 0)
	{
		perror("clientTest> erreur send ligne prochainCoup");
		return -3;
	}
	err = send(sock, &data, sizeof(int), 0);
	if (err <= 0)
	{
		perror("clientTest> erreur send colonne prochainCoup");
		return -4;
	}
	err = send(sock, &data, sizeof(int), 0);
	if (err <= 0)
	{
		perror("clientTest> erreur send propriete prochainCoup");
		return -5;
	}

	shutdownClose(sock);
	return 0;
}

int prochainCoupTest3(int sock)
{
	int data, err;

	data = htonl(1);
	err = send(sock, &data, sizeof(int), 0);
	if (err <= 0)
	{
		perror("clientTest> erreur send estBloque prochainCoup");
		return -1;
	}

	shutdownClose(sock);
	return 0;
}

int adversaireCoupTest(int sock)
{
	int err, data;
	TCoupReq* coupReq = malloc(sizeof(TCoupReq));

	coupReq->idRequest = COUP;
	coupReq->estBloque = 1;
	coupReq->numPartie = 1;
	coupReq->pion.typePion = PAVE;
	coupReq->pion.coulPion = NOIR;
	coupReq->posPion.l = DEUX;
	coupReq->posPion.c = B;
	coupReq->propCoup = GAGNE;

	adversaireCoup(sock, coupReq);

	err = recv(sock, &data, sizeof(int), 0);
	if (err <= 0)
	{
		perror("clientTest> erreur recv CODE_COUP_ADV adversaireCoupTest");
		return -1;
	}
	err = recv(sock, &data, sizeof(int), 0);
	if (err <= 0)
	{
		perror("clientTest> erreur recv estBloque adversaireCoupTest");
		return -2;
	}
	err = recv(sock, &data, sizeof(int), 0);
	if (err <= 0)
	{
		perror("clientTest> erreur recv typePion adversaireCoupTest");
		return -3;
	}
	err = recv(sock, &data, sizeof(int), 0);
	if (err <= 0)
	{
		perror("clientTest> erreur recv ligne adversaireCoupTest");
		return -4;
	}
	err = recv(sock, &data, sizeof(int), 0);
	if (err <= 0)
	{
		perror("clientTest> erreur recv colonne adversaireCoupTest");
		return -5;
	}
	err = recv(sock, &data, sizeof(int), 0);
	if (err <= 0)
	{
		perror("clientTest> erreur recv propCoup adversaireCoupTest");
		return -6;
	}

	shutdownClose(sock);
	return 0;
}

int jouerPartieTest1(int sock)
{
	int err;
	TCoupReq* coupReq = malloc(sizeof(TCoupReq));
	TCoupRep* coupRep = malloc(sizeof(TCoupRep));
	FILE* file;

	usleep(1000000);
	file = fopen("testData_jouerPartie.txt", "r");
	printf("fopend");
    if ( file == NULL ) {
        printf("Cannot open file testData_jouerPartie.txt\n");
        exit(0);
    }
    while (!feof(file)) {
    	printf("writing");
        fputc(fgetc(file), stdin);
    }
    fclose(file);
	err = recv(sock, coupReq, sizeof(TCoupReq), 0);
	if (err <= 0)
	{
		perror("clientTest> erreur recv TCoupReq jouerPartieTest1");
		return -1;
	}
	err = send(sock, coupRep, sizeof(TCoupRep), 0);
	if (err <= 0)
	{
		perror("clientTest> erreur send TCoupRep jouerPartieTest1");
		return -2;
	}

	coupRep->err = 0;
	coupRep->validCoup = 0;
	coupRep->propCoup = 1;

	err = jouerPartie(sock, 1, BLANC, 1, 1);

	shutdownClose(sock);
	return 0;
}

int jouerPartieTest2(int sock)
{
	int err;
	TCoupRep coupRep;

	coupRep.err = ERR_OK;
	coupRep.validCoup = OK;
	coupRep.propCoup = GAGNE;

	err = send(sock, &coupRep, sizeof(TCoupRep), 0);
	if (err <= 0)
	{
		perror("clientTest> erreur send TCoupRep jouerPartieTest2");
		return -1;
	}

	shutdownClose(sock);
	return 0;
}

int jouerPartieTest3(int sock)
{
	int err;
	TCoupRep coupRep;

	coupRep.err = ERR_OK;
	coupRep.validCoup = OK;
	coupRep.propCoup = CONT;

	err = send(sock, &coupRep, sizeof(TCoupRep), 0);
	if (err <= 0)
	{
		perror("clientTest> erreur send TCoupRep jouerPartieTest3");
		return -1;
	}

	shutdownClose(sock);
	return 0;
}

int jouerPartieIATest1(int sock)
{
	int err, data;

	err = recv(sock, &data, sizeof(int), 0);
    if (err <= 0)
    {
        perror("clientTest> erreur recv code nv partie jouerPartieIA1");
        return -1;
    }
    data = htonl(-1);
    err = send(sock, &data, sizeof(int), 0);
    if (err <= 0)
    {
        perror("clientTest> erreur send !CODE_OK jouerPartieIA1");
        return -2;
    }
	err = recv(sock, &data, sizeof(int), 0);
    if (err <= 0)
    {
        perror("clientTest> erreur recv CODE_COUP_SELF jouerPartieIA1");
        return -3;
    }

	shutdownClose(sock);
	return 0;
}

int jouerPartieIATest2(int sock)
{
	int err, sockConn, sockTrans, tailleAdr, data;
	struct sockaddr_in adr;
	TCoupReq coupReq;
	TCoupRep coupRep;

	sockConn = socketServeur(8100);
	sockTrans = accept(sockConn,
			(struct sockaddr *)&adr,
			(socklen_t *)&tailleAdr);

	err = recv(sock, &data, sizeof(int), 0);
    if (err <= 0)
    {
        perror("clientTest> erreur recv code nv partie jouerPartieIA2");
        return -1;
    }
    printf("nv_partie %d\n", data);
    data = htonl(CODE_OK);
    err = send(sock, &data, sizeof(int), 0);
    if (err <= 0)
    {
        perror("clientTest> erreur send CODE_OK jouerPartieIA2");
        return -2;
    }

	err = recv(sock, &data, sizeof(int), 0);
    if (err <= 0)
    {
        perror("clientTest> erreur recv CODE_COUP_SELF jouerPartieIA2");
        return -3;
    }
    printf("CODE_COUP_SELF %d\n", data);
    data = htonl(CODE_OK);
    err = send(sock, &data, sizeof(int), 0);
    if (err <= 0)
    {
        perror("clientTest> erreur send CODE_OK jouerPartieIA2");
        return -4;
    }

	data = htonl(1);
	err = send(sock, &data, sizeof(int), 0);
	if (err <= 0)
	{
		perror("clientTest> erreur send estBloque jouerPartieIA2");
		return -5;
	}
	err = send(sock, &data, sizeof(int), 0);
	if (err <= 0)
	{
		perror("clientTest> erreur send typePion jouerPartieIA2");
		return -6;
	}
	err = send(sock, &data, sizeof(int), 0);
	if (err <= 0)
	{
		perror("clientTest> erreur send ligne jouerPartieIA2");
		return -7;
	}
	err = send(sock, &data, sizeof(int), 0);
	if (err <= 0)
	{
		perror("clientTest> erreur send colonne jouerPartieIA2");
		return -8;
	}
	err = send(sock, &data, sizeof(int), 0);
	if (err <= 0)
	{
		perror("clientTest> erreur send propriete jouerPartieIA2");
		return -9;
	}

	err = recv(sockTrans, &coupReq, sizeof(TCoupReq), 0);
    if (err <= 0)
    {
        perror("clientTest> erreur recv TCoupReq jouerPartieIA2");
        return -10;
    }

	coupRep.err = ERR_OK;
	coupRep.validCoup = OK;
	coupRep.propCoup = GAGNE;
	err = send(sockTrans, &coupRep, sizeof(TCoupRep), 0);
	if (err <= 0)
	{
		perror("clientTest> erreur send TCoupRep jouerPartieIA2");
		return -11;
	}

	shutdownCloseBoth(sock, sockTrans);
	shutdownClose(sockConn);
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
		printf("clientTest> connexion acceptée\n");

		err = recv(sockTrans, &nTest, sizeof(int), 0);
		if (err <= 0)
		{
			perror("clientTest> erreur recv nTest");
			return -1;
		}

		printf("clientTest> code recu : %d\n", nTest);
		switch (nTest)
		{
			case 1:
				verifCodeRepTest(sockTrans);
				break;

			case 2:
				recvIntFromJavaTest(sockTrans);
				break;

			case 3:
				prochainCoupTest1(sockTrans);
				break;

			case 5:
				prochainCoupTest3(sockTrans);
				break;

			case 9:
				adversaireCoupTest(sockTrans);
				break;

			case 10:
				jouerPartieTest1(sockTrans);
				break;

			case 12:
				jouerPartieTest2(sockTrans);
				break;

			case 13:
				jouerPartieTest3(sockTrans);
				break;

			case 15:
				jouerPartieIATest1(sockTrans);
				break;

			case 16:
				jouerPartieIATest2(sockTrans);
				break;

			default:
				testsContinue = 0;
				break;
		}
	}
	shutdownClose(sockConn);

	return 0;
}