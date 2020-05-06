#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <string.h>
#include "../src/protocolQuantik.h"
#include "../src/libSockets.h"
#include "../src/libServeurArbitre.h"
#include "minunit.h"

MU_TEST(test_verifIdRequete1)
{
	int err, sock = -1;
	printf("test> verifIdRequete1\n");

	err = verifIdRequete(&sock, -1);
	mu_assert(err == -1, "erreur verifIdRequete1 return!=-1");
}

MU_TEST(test_verifIdRequete2)
{
	int err = 1, sock;
	printf("test> verifIdRequete2\n");

	sock = socketClient("127.0.0.1", 8080);
	err = send(sock, &err, sizeof(int), 0);
	if (err <= 0)
	{
		mu_fail("erreur send code test verifIdRequete2");
	}

	err = verifIdRequete(&sock, PARTIE);
	mu_assert(err == -4, "erreur verifIdRequete2 return!=-4");

	shutdownClose(sock);
}

MU_TEST(test_verifIdRequete3)
{
	int err = 2, sock;
	printf("test> verifIdRequete3\n");

	sock = socketClient("127.0.0.1", 8080);
	err = send(sock, &err, sizeof(int), 0);
	if (err <= 0)
	{
		mu_fail("erreur send code test verifIdRequete3");
	}

	err = verifIdRequete(&sock, COUP);
	mu_assert(err == -4, "erreur verifIdRequete3 return!=-4");

	shutdownClose(sock);
}

MU_TEST(test_verifIdRequete4)
{
	int err = 4, sock;
	printf("test> verifIdRequete5\n");

	sock = socketClient("127.0.0.1", 8080);
	err = send(sock, &err, sizeof(int), 0);
	if (err <= 0)
	{
		mu_fail("erreur send code test verifIdRequete4");
	}

	err = verifIdRequete(&sock, PARTIE);
	mu_assert(err == 0, "erreur verifIdRequete4 return!=0");

	shutdownClose(sock);
}

MU_TEST(test_connecteJoueur)
{
	int err = 5, sock, sockConn, sockTarget, data;
	TPartieReq* partieReq = malloc(sizeof(TPartieReq));
	printf("test> connecteJoueur\n");

	sock = socketClient("127.0.0.1", 8080);
	err = send(sock, &err, sizeof(int), 0);
	if (err <= 0)
	{
		mu_fail("erreur send code test connecteJoueur");
	}

	sockConn = socketServeur(8081);
	connecteJoueur(&sockTarget, sockConn, partieReq);

	err = recv(sock, &data, sizeof(int), 0);
	if (err <= 0)
	{
		mu_fail("erreur recv target socket connecteJoueur");
	}
	mu_assert(sockTarget == data, "erreur connecteJoueur sock!=attendu");
	mu_assert(partieReq->idReq == PARTIE, "erreur connecteJoueur idReq!=PARTIE");
	mu_assert(partieReq->coulPion == BLANC, "erreur connecteJoueur coulPion!=BLANC");
	mu_assert(strcmp(partieReq->nomJoueur, "joueur") == 0, "erreur connecteJoueur nomJoueur!='joueur'");

	shutdownCloseBoth(sockConn, sock);
}

MU_TEST(test_ackJoueursConnectes)
{
	int err = 6, sock, sockConn, data = -1, dummy = -1, sockTrans, tailleAdr;
	struct sockaddr_in adr;
	TPartieRep* partieRep1 = malloc(sizeof(TPartieRep));
	TPartieRep* partieRep2 = malloc(sizeof(TPartieRep));
	printf("test> ackJoueurConnectes\n");

	sock = socketClient("127.0.0.1", 8080);
	err = send(sock, &err, sizeof(int), 0);
	if (err <= 0)
	{
		mu_fail("erreur send code test ackJoueursConnectes");
	}

	sockConn = socketServeur(8081);
	sockTrans = accept(sockConn,
		(struct sockaddr *)&adr,
		(socklen_t *)&tailleAdr);

	err = ackJoueursConnectes(&data, &sockTrans, partieRep1, partieRep2);
	mu_assert(err == -1, "erreur ackJoueursConnectes return!=-1");

	data = -1;
	err = ackJoueursConnectes(&data, &dummy, partieRep1, partieRep2);
	mu_assert(err == -2, "erreur ackJoueurConnectes return!=-2");

	sockTrans = accept(sockConn,
		(struct sockaddr *)&adr,
		(socklen_t *)&tailleAdr);

	err = ackJoueursConnectes(&sockTrans, &data, partieRep1, partieRep2);
	mu_assert(err == 0, "erreur ackJoueursConnectes return!=0");

	shutdownCloseBoth(sock, sockTrans);
	shutdownClose(sockConn);
}

MU_TEST(test_paireJoueurValides)
{
	int err = 7, sock, sock1, sock2, sockConn;
	printf("test> paireJoueurValides\n");

	sock = socketClient("127.0.0.1", 8080);
	err = send(sock, &err, sizeof(int), 0);
	if (err <= 0)
	{
		mu_fail("erreur send code test paireJoueurValides");
	}

	sockConn = socketServeur(8081);
	err = paireJoueurValides(&sock1, &sock2, sockConn);
	mu_assert(err == 0, "erreur paireJoueurValides return!=0");

	shutdownCloseBoth(sock1, sock2);
	shutdownCloseBoth(sockConn, sock);
}

MU_TEST(test_envoyerRepCoup)
{
	int err = 8, sock;
	TCoupRep* coupRep = malloc(sizeof(TCoupRep));
	printf("test> envoyerRepCoup\n");

	sock = socketClient("127.0.0.1", 8080);
	err = send(sock, &err, sizeof(int), 0);
	if (err <= 0)
	{
		mu_fail("erreur send code test ackJoueursConnectes");
	}

	err = envoyerRepCoup(-1, -1, coupRep);
	mu_assert(err == -1, "erreur envoyerRepCoup return!=-1");

	err = envoyerRepCoup(sock, -1, coupRep);
	mu_assert(err == -2, "erreur envoyerRepCoup return!=-2");

	err = envoyerRepCoup(sock, sock, coupRep);
	mu_assert(err == 0, "erreur envoyerRepCoup return!=0");

	shutdownClose(sock);
}

MU_TEST(test_traiterCoup1)
{
	printf("test> traiterCoup1\n");
	int err = traiterCoup(-1, -1, -1, -1);
	mu_assert(err == -1, "erreur traiterCoup1 return!=-1");

	err = traiterCoup(-1, -1, 0, -1);
	mu_assert(err == -2, "erreur traiterCoup1 return!=-2");
}

MU_TEST(test_jouerPartie1)
{
	printf("test> jouerPartie1\n");
	int err = jouerPartie(-1, -1);
	mu_assert(err == -2, "erreur jouerPartie1 return!=-2");
}

MU_TEST_SUITE(test_libServeurArbitre) 
{
	MU_RUN_TEST(test_verifIdRequete1);
	MU_RUN_TEST(test_verifIdRequete2);
	MU_RUN_TEST(test_verifIdRequete3);
	MU_RUN_TEST(test_verifIdRequete4);
	MU_RUN_TEST(test_connecteJoueur);
	MU_RUN_TEST(test_ackJoueursConnectes);
	MU_RUN_TEST(test_paireJoueurValides);
	MU_RUN_TEST(test_envoyerRepCoup);
	MU_RUN_TEST(test_traiterCoup1);
	MU_RUN_TEST(test_jouerPartie1);
}

int main (int argc, char* argv[]) 
{
	int err = 0, sock;

	MU_RUN_SUITE(test_libServeurArbitre);
	MU_REPORT();

	usleep(100000);
	printf("test> envoi signal fin de tests\n");
	sock = socketClient("127.0.0.1", 8080);
	err = send(sock, &err, sizeof(int), 0);
	if (err <= 0) 
	{
		perror("*** échec envoi signal fin des tests");
	}

	return MU_EXIT_CODE;
}